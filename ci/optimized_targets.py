#
# Copyright 2024, The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from abc import ABC
import argparse
import functools
import json
import logging
import os
import pathlib
import subprocess

from build_context import BuildContext
import metrics_agent
import test_mapping_module_retriever
import test_discovery_agent


class OptimizedBuildTarget(ABC):
  """A representation of an optimized build target.

  This class will determine what targets to build given a given build_cotext and
  will have a packaging function to generate any necessary output zips for the
  build.
  """

  _SOONG_UI_BASH_PATH = 'build/soong/soong_ui.bash'
  _PREBUILT_SOONG_ZIP_PATH = 'prebuilts/build-tools/linux-x86/bin/soong_zip'

  def __init__(
      self,
      target: str,
      build_context: BuildContext,
      args: argparse.Namespace,
      test_infos,
  ):
    self.target = target
    self.build_context = build_context
    self.args = args
    self.test_infos = test_infos

  def get_build_targets(self) -> set[str]:
    features = self.build_context.enabled_build_features
    if self.get_enabled_flag() in features:
      self.modules_to_build = self.get_build_targets_impl()
      return self.modules_to_build

    if self.target == 'general-tests':
      self._report_info_metrics_silently('general-tests.zip')
    self.modules_to_build = {self.target}
    return {self.target}

  def get_package_outputs_commands(self) -> list[list[str]]:
    features = self.build_context.enabled_build_features
    if self.get_enabled_flag() in features:
      return self.get_package_outputs_commands_impl()

    return []

  def get_package_outputs_commands_impl(self) -> list[list[str]]:
    raise NotImplementedError(
        'get_package_outputs_commands_impl not implemented in'
        f' {type(self).__name__}'
    )

  def get_enabled_flag(self):
    raise NotImplementedError(
        f'get_enabled_flag not implemented in {type(self).__name__}'
    )

  def get_build_targets_impl(self) -> set[str]:
    raise NotImplementedError(
        f'get_build_targets_impl not implemented in {type(self).__name__}'
    )

  def _generate_zip_options_for_items(
      self,
      prefix: str = '',
      relative_root: str = '',
      list_files: list[str] | None = None,
      files: list[str] | None = None,
      directories: list[str] | None = None,
  ) -> list[str]:
    if not list_files and not files and not directories:
      raise RuntimeError(
          f'No items specified to be added to zip! Prefix: {prefix}, Relative'
          f' root: {relative_root}'
      )
    command_segment = []
    # These are all soong_zip options so consult soong_zip --help for specifics.
    if prefix:
      command_segment.append('-P')
      command_segment.append(prefix)
    if relative_root:
      command_segment.append('-C')
      command_segment.append(relative_root)
    if list_files:
      for list_file in list_files:
        command_segment.append('-l')
        command_segment.append(list_file)
    if files:
      for file in files:
        command_segment.append('-f')
        command_segment.append(file)
    if directories:
      for directory in directories:
        command_segment.append('-D')
        command_segment.append(directory)

    return command_segment

  def _query_soong_vars(
      self, src_top: pathlib.Path, soong_vars: list[str]
  ) -> dict[str, str]:
    process_result = subprocess.run(
        args=[
            f'{src_top / self._SOONG_UI_BASH_PATH}',
            '--dumpvars-mode',
            f'--abs-vars={" ".join(soong_vars)}',
        ],
        env=os.environ,
        check=False,
        capture_output=True,
        text=True,
    )
    if not process_result.returncode == 0:
      logging.error('soong dumpvars command failed! stderr:')
      logging.error(process_result.stderr)
      raise RuntimeError('Soong dumpvars failed! See log for stderr.')

    if not process_result.stdout:
      raise RuntimeError(
          'Necessary soong variables ' + soong_vars + ' not found.'
      )

    try:
      return {
          line.split('=')[0]: line.split('=')[1].strip("'")
          for line in process_result.stdout.strip().split('\n')
      }
    except IndexError as e:
      raise RuntimeError(
          'Error parsing soong dumpvars output! See output here:'
          f' {process_result.stdout}',
          e,
      )

  def _base_zip_command(
      self, src_top: pathlib.Path, dist_dir: pathlib.Path, name: str
  ) -> list[str]:
    return [
        f'{src_top / self._PREBUILT_SOONG_ZIP_PATH }',
        '-d',
        '-o',
        f'{dist_dir / name}',
    ]

  def _report_info_metrics_silently(self, artifact_name):
    try:
      metrics_agent_instance = metrics_agent.MetricsAgent.instance()
      targets = self.get_build_targets_impl()
      metrics_agent_instance.report_optimized_target(self.target)
      metrics_agent_instance.add_target_artifact(self.target, artifact_name, 0, targets)
    except Exception as e:
      logging.error(f'error while silently reporting metrics: {e}')



class NullOptimizer(OptimizedBuildTarget):
  """No-op target optimizer.

  This will simply build the same target it was given and do nothing for the
  packaging step.
  """

  def __init__(self, target):
    self.target = target

  def get_build_targets(self):
    return {self.target}

  def get_package_outputs_commands(self):
    return []


class ChangeInfo:

  def __init__(self, change_info_file_path):
    try:
      with open(change_info_file_path) as change_info_file:
        change_info_contents = json.load(change_info_file)
    except json.decoder.JSONDecodeError:
      logging.error(f'Failed to load CHANGE_INFO: {change_info_file_path}')
      raise

    self._change_info_contents = change_info_contents

  def get_changed_paths(self) -> set[str]:
    changed_paths = set()
    for change in self._change_info_contents['changes']:
      project_path = change.get('projectPath') + '/'

      for revision in change.get('revisions'):
        for file_info in revision.get('fileInfos'):
          file_path = file_info.get('path')
          dir_path = os.path.dirname(file_path)
          changed_paths.add(project_path + dir_path)

    return changed_paths

  def find_changed_files(self) -> set[str]:
    changed_files = set()

    for change in self._change_info_contents['changes']:
      project_path = change.get('projectPath') + '/'

      for revision in change.get('revisions'):
        for file_info in revision.get('fileInfos'):
          changed_files.add(project_path + file_info.get('path'))

    return changed_files


class GeneralTestsOptimizer(OptimizedBuildTarget):
  """general-tests optimizer

  This optimizer uses test discovery to build a list of modules that are needed by all tests configured for the build. These modules are then build and packaged by the optimizer in the same way as they are in a normal build.
  """

  # List of modules that are built alongside general-tests as dependencies.
  _REQUIRED_MODULES = frozenset([
      'cts-tradefed',
      'vts-tradefed',
      'compatibility-host-util',
  ])

  def get_build_targets_impl(self) -> set[str]:
    self._general_tests_outputs = self._get_general_tests_outputs()
    test_modules = self._get_test_discovery_modules()

    modules_to_build = set(self._REQUIRED_MODULES)
    self._build_outputs = []
    for module in test_modules:
      module_outputs = [output for output in self._general_tests_outputs if module in output]
      if module_outputs:
        modules_to_build.add(module)
        self._build_outputs.extend(module_outputs)

    return modules_to_build

  def _get_general_tests_outputs(self) -> list[str]:
    src_top = pathlib.Path(os.environ.get('TOP', os.getcwd()))
    soong_vars = self._query_soong_vars(
        src_top,
        [
            'PRODUCT_OUT',
        ],
    )
    product_out = pathlib.Path(soong_vars.get('PRODUCT_OUT'))
    with open(f'{product_out / "general-tests_files"}') as general_tests_list_file:
      general_tests_list = general_tests_list_file.readlines()
    with open(f'{product_out / "general-tests_host_files"}') as general_tests_list_file:
      self._general_tests_host_outputs = general_tests_list_file.readlines()
    with open(f'{product_out / "general-tests_target_files"}') as general_tests_list_file:
      self._general_tests_target_outputs = general_tests_list_file.readlines()
    return general_tests_list


  def _get_test_discovery_modules(self) -> set[str]:
    change_info = ChangeInfo(os.environ.get('CHANGE_INFO'))
    change_paths = change_info.get_changed_paths()
    test_modules = set()
    for test_info in self.test_infos:
      tf_command = self._build_tf_command(test_info, change_paths)
      discovery_agent = test_discovery_agent.TestDiscoveryAgent(tradefed_args=tf_command, test_mapping_zip_path=os.environ.get('DIST_DIR')+'/test_mappings.zip')
      modules, dependencies = discovery_agent.discover_test_mapping_test_modules()
      for regex in modules:
        test_modules.add(regex)
    return test_modules


  def _build_tf_command(self, test_info, change_paths) -> list[str]:
    command = [test_info.command]
    for extra_option in test_info.extra_options:
      if not extra_option.get('key'):
        continue
      arg_key = '--' + extra_option.get('key')
      if arg_key == '--build-id':
        command.append(arg_key)
        command.append(os.environ.get('BUILD_NUMBER'))
        continue
      if extra_option.get('values'):
        for value in extra_option.get('values'):
          command.append(arg_key)
          command.append(value)
      else:
        command.append(arg_key)
    if test_info.is_test_mapping:
      for change_path in change_paths:
        command.append('--test-mapping-path')
        command.append(change_path)

    return command

  def get_package_outputs_commands_impl(self):
    src_top = pathlib.Path(os.environ.get('TOP', os.getcwd()))
    dist_dir = pathlib.Path(os.environ.get('DIST_DIR'))
    tmp_dir = pathlib.Path(os.environ.get('TMPDIR'))
    print(f'modules: {self.modules_to_build}')

    host_outputs = [str(src_top) + '/' + file for file in self._general_tests_host_outputs if any('/'+module+'/' in file for module in self.modules_to_build)]
    target_outputs = [str(src_top) + '/' + file for file in self._general_tests_target_outputs if any('/'+module+'/' in file for module in self.modules_to_build)]
    host_config_files = [file for file in host_outputs if file.endswith('.config\n')]
    target_config_files = [file for file in target_outputs if file.endswith('.config\n')]
    logging.info(host_outputs)
    logging.info(target_outputs)
    with open(f"{tmp_dir / 'host.list'}", 'w') as host_list_file:
      for output in host_outputs:
        host_list_file.write(output)
    with open(f"{tmp_dir / 'target.list'}", 'w') as target_list_file:
      for output in target_outputs:
        target_list_file.write(output)
    soong_vars = self._query_soong_vars(
        src_top,
        [
            'PRODUCT_OUT',
            'SOONG_HOST_OUT',
            'HOST_OUT',
        ],
    )
    product_out = pathlib.Path(soong_vars.get('PRODUCT_OUT'))
    soong_host_out = pathlib.Path(soong_vars.get('SOONG_HOST_OUT'))
    host_out = pathlib.Path(soong_vars.get('HOST_OUT'))
    zip_commands = []

    zip_commands.extend(
        self._get_zip_test_configs_zips_commands(
            src_top,
            dist_dir,
            host_out,
            product_out,
            host_config_files,
            target_config_files,
        )
    )

    zip_command = self._base_zip_command(src_top, dist_dir, 'general-tests.zip')
    # Add host testcases.
    if host_outputs:
      zip_command.extend(
          self._generate_zip_options_for_items(
              prefix='host',
              relative_root=str(host_out),
              list_files=[f"{tmp_dir / 'host.list'}"],
          )
      )

    # Add target testcases.
    if target_outputs:
      zip_command.extend(
          self._generate_zip_options_for_items(
              prefix='target',
              relative_root=str(product_out),
              list_files=[f"{tmp_dir / 'target.list'}"],
          )
      )

    # TODO(lucafarsi): Push this logic into a general-tests-minimal build command
    # Add necessary tools. These are also hardcoded in general-tests.mk.
    framework_path = soong_host_out / 'framework'

    zip_command.extend(
        self._generate_zip_options_for_items(
            prefix='host/tools',
            relative_root=str(framework_path),
            files=[
                f"{framework_path / 'cts-tradefed.jar'}",
                f"{framework_path / 'compatibility-host-util.jar'}",
                f"{framework_path / 'vts-tradefed.jar'}",
            ],
        )
    )

    zip_command.append('-sha256')

    zip_commands.append(zip_command)
    return zip_commands

  def _get_zip_test_configs_zips_commands(
      self,
      src_top: pathlib.Path,
      dist_dir: pathlib.Path,
      host_out: pathlib.Path,
      product_out: pathlib.Path,
      host_config_files: list[str],
      target_config_files: list[str],
  ) -> tuple[list[str], list[str]]:
    """Generate general-tests_configs.zip and general-tests_list.zip.

    general-tests_configs.zip contains all of the .config files that were
    built and general-tests_list.zip contains a text file which lists
    all of the .config files that are in general-tests_configs.zip.

    general-tests_configs.zip is organized as follows:
    /
      host/
        testcases/
          test_1.config
          test_2.config
          ...
      target/
        testcases/
          test_1.config
          test_2.config
          ...

    So the process is we write out the paths to all the host config files into
    one
    file and all the paths to the target config files in another. We also write
    the paths to all the config files into a third file to use for
    general-tests_list.zip.

    Args:
      dist_dir: dist directory.
      host_out: host out directory.
      product_out: product out directory.
      host_config_files: list of all host config files.
      target_config_files: list of all target config files.

    Returns:
      The commands to generate general-tests_configs.zip and
      general-tests_list.zip
    """
    with open(
        f"{host_out / 'host_general-tests_list'}", 'w'
    ) as host_list_file, open(
        f"{product_out / 'target_general-tests_list'}", 'w'
    ) as target_list_file, open(
        f"{host_out / 'general-tests_list'}", 'w'
    ) as list_file:

      for config_file in host_config_files:
        host_list_file.write(f'{config_file}' + '\n')
        list_file.write('host/' + os.path.relpath(config_file, host_out) + '\n')

      for config_file in target_config_files:
        target_list_file.write(f'{config_file}' + '\n')
        list_file.write(
            'target/' + os.path.relpath(config_file, product_out) + '\n'
        )

    zip_commands = []

    tests_config_zip_command = self._base_zip_command(
        src_top, dist_dir, 'general-tests_configs.zip'
    )
    tests_config_zip_command.extend(
        self._generate_zip_options_for_items(
            prefix='host',
            relative_root=str(host_out),
            list_files=[f"{host_out / 'host_general-tests_list'}"],
        )
    )

    tests_config_zip_command.extend(
        self._generate_zip_options_for_items(
            prefix='target',
            relative_root=str(product_out),
            list_files=[f"{product_out / 'target_general-tests_list'}"],
        ),
    )

    zip_commands.append(tests_config_zip_command)

    tests_list_zip_command = self._base_zip_command(
        src_top, dist_dir, 'general-tests_list.zip'
    )
    tests_list_zip_command.extend(
        self._generate_zip_options_for_items(
            relative_root=str(host_out),
            files=[f"{host_out / 'general-tests_list'}"],
        )
    )
    zip_commands.append(tests_list_zip_command)

    return zip_commands

  def get_enabled_flag(self):
    return 'general_tests_optimized'

  @classmethod
  def get_optimized_targets(cls) -> dict[str, OptimizedBuildTarget]:
    return {'general-tests': functools.partial(cls)}


OPTIMIZED_BUILD_TARGETS = {}
OPTIMIZED_BUILD_TARGETS.update(GeneralTestsOptimizer.get_optimized_targets())
