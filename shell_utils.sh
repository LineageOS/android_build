# Copyright (C) 2022 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function gettop
{
    local TOPFILE=build/make/core/envsetup.mk
    # The ${TOP-} expansion allows this to work even with set -u
    if [ -n "${TOP:-}" -a -f "${TOP:-}/$TOPFILE" ] ; then
        # The following circumlocution ensures we remove symlinks from TOP.
        (cd "$TOP"; PWD= /bin/pwd)
    else
        if [ -f $TOPFILE ] ; then
            # The following circumlocution (repeated below as well) ensures
            # that we record the true directory name and not one that is
            # faked up with symlink names.
            PWD= /bin/pwd
        else
            local HERE=$PWD
            local T=
            while [ \( ! \( -f $TOPFILE \) \) -a \( "$PWD" != "/" \) ]; do
                \cd ..
                T=`PWD= /bin/pwd -P`
            done
            \cd "$HERE"
            if [ -f "$T/$TOPFILE" ]; then
                echo "$T"
            fi
        fi
    fi
}

# Asserts that the root of the tree can be found.
if [ -z "${IMPORTING_ENVSETUP:-}" ] ; then
function require_top
{
    TOP=$(gettop)
    if [[ ! $TOP ]] ; then
        echo "Can not locate root of source tree. $(basename $0) must be run from within the Android source tree or TOP must be set." >&2
        exit 1
    fi
}
fi

# Asserts that the lunch variables have been set
if [ -z "${IMPORTING_ENVSETUP:-}" ] ; then
function require_lunch
{
    if [[ ! $TARGET_PRODUCT || ! $TARGET_RELEASE || ! $TARGET_BUILD_VARIANT  ]] ; then
        echo "Please run lunch and try again." >&2
        exit 1
    fi
}
fi

function set_network_file_system_type_env_var() {
  local top=$(gettop)
  local out_dir=$(getoutdir)
  local cartfs_mount_point=$(cartfs_mount_point)

  local nfs_type=local

  # The options are:
  # - cog-cartfs-symlink: out is a symlink to a CartFS path in a Cog workspace.
  # - local-cartfs-symlink: out is a symlink to a CartFS path in a local workspace.
  # - cog-symlink: $top starts with /google/cog.
  # - abfs: .abfs.sock exists in the workspace.
  if [[ -n "$cartfs_mount_point" && -L "$out_dir" && "$(readlink "$out_dir")" =~ ^/google/cartfs/mount ]]; then
    if [[ "$top" =~ ^/google/cog ]]; then
      nfs_type=cog-cartfs-symlink
    else
      nfs_type=local-cartfs-symlink
    fi
  elif [[ "$top" =~ ^/google/cog ]]; then
    nfs_type=cog-symlink
  elif [[ -f "$top/.abfs.sock" ]]; then
    nfs_type=abfs
  fi

  export NETWORK_FILE_SYSTEM_TYPE=$nfs_type
}

# This function sets up the build environment to be appropriate for Cog.
function setup_cog_env_if_needed() {
  local top=$(gettop)

  # return early if not in a cog workspace
  if [[ ! "$top" =~ ^/google/cog ]]; then
    return 0
  fi

  clean_deleted_workspaces_in_cartfs

  setup_cog_symlink

  export ANDROID_BUILD_ENVIRONMENT_CONFIG="googler-cog"

  # Running repo command within Cog workspaces is not supported, so override
  # it with this function. If the user is running repo within a Cog workspace,
  # we'll fail with an error, otherwise, we run the original repo command with
  # the given args.
  if ! ORIG_REPO_PATH=`which repo`; then
    return 0
  fi
  function repo {
    if [[ "${PWD}" == /google/cog/* ]]; then
      echo -e "\e[01;31mERROR:\e[0mrepo command is disallowed within Cog workspaces."
      kill -INT $$ # exits the script without exiting the user's shell
    fi
    ${ORIG_REPO_PATH} "$@"
  }
}

# creates a symlink for the out/ dir when inside a cog workspace.
function setup_cog_symlink() {
  local out_dir=$(getoutdir)
  local top=$(gettop)

  # return early if out dir is already a symlink.
  if [[ -L "$out_dir" ]]; then
    destination=$(readlink "$out_dir")
    # ensure the destination exists.
    mkdir -p "$destination"
    return 0
  fi

  # return early if out dir is not in the workspace
  if [[ ! "$out_dir" =~ ^$top/ ]]; then
    return 0
  fi

  local link_destination="${HOME}/.cog/android-build-out"

  # When cartfs is mounted, use it as the destination for output directory.
  local cartfs_mount_point=$(cartfs_mount_point)
  if [[ -n "$cartfs_mount_point" ]]; then
    local cog_workspace_name="$(basename "$(dirname "${top}")")"
    link_destination="${cartfs_mount_point}/${cog_workspace_name}/out"
    setup_cartfs_incremental_build "${link_destination}" "${cartfs_mount_point}"
  else
    # If CartFS is not mounted, check to see if it is installed (no mount but
    # being installed implies it was disabled). If it is installed, then don't
    # display any messages to the user. If it isn't installed, then message the
    # user to install it, but don't stop the script.
    if ! command -v cartfs &> /dev/null; then
      echo "***"
      echo "🚨 Install CartFS for more reliable builds. See go/cartfs-with-cog for installation instructions! 🚨"
      echo "***"
    fi
  fi

  # remove existing out/ dir if it exists
  if [[ -d "$out_dir" ]]; then
    echo "Detected existing out/ directory in the Cog workspace which is not supported. Repairing workspace by removing it and creating the symlink to ${link_destination}"
    if ! rm -rf "$out_dir"; then
      echo "Failed to remove existing out/ directory: $out_dir" >&2
      kill -INT $$ # exits the script without exiting the user's shell
    fi
  fi

  # create symlink
  echo "Creating symlink: $out_dir -> $link_destination"
  mkdir -p ${link_destination}
  if ! ln -s "$link_destination" "$out_dir"; then
    echo "Failed to create cog symlink: $out_dir -> $link_destination" >&2
    kill -INT $$ # exits the script without exiting the user's shell
  fi
}

function getoutdir
{
    local top=$(gettop)
    local out_dir="${OUT_DIR:-}"
    if [[ -z "${out_dir}" ]]; then
        if [[ -n "${OUT_DIR_COMMON_BASE:-}" && -n "${top}" ]]; then
            out_dir="${OUT_DIR_COMMON_BASE}/$(basename ${top})"
        else
            out_dir="out"
        fi
    fi
    if [[ "${out_dir}" != /* ]]; then
        out_dir="${top}/${out_dir}"
    fi
    echo "${out_dir}"
}

# Pretty print the build status and duration
function _wrap_build()
{
    if [[ "${ANDROID_QUIET_BUILD:-}" == true ]]; then
      "$@"
      return $?
    fi
    local start_time=$(date +"%s")
    "$@"
    local ret=$?
    local end_time=$(date +"%s")
    local tdiff=$(($end_time-$start_time))
    local hours=$(($tdiff / 3600 ))
    local mins=$((($tdiff % 3600) / 60))
    local secs=$(($tdiff % 60))
    local ncolors=$(tput colors 2>/dev/null)
    if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]; then
        color_failed=$'\E'"[0;31m"  # red
        color_success=$'\E'"[0;32m"  # green
        color_warning=$'\E'"[0;33m"  # yellow
        color_info=$'\E'"[0;36m"  # cyan
        color_reset=$'\E'"[00m"
    else
        color_failed=""
        color_success=""
        color_warning=""
        color_info=""
        color_reset=""
    fi

    echo
    if [ $ret -eq 0 ] ; then
        echo -n "${color_success}#### build completed successfully "
    else
        echo -n "${color_failed}#### failed to build some targets "
    fi
    if [ $hours -gt 0 ] ; then
        printf "(%02d:%02d:%02d (hh:mm:ss))" $hours $mins $secs
    elif [ $mins -gt 0 ] ; then
        printf "(%02d:%02d (mm:ss))" $mins $secs
    elif [ $secs -gt 0 ] ; then
        printf "(%d seconds)" $secs
    fi
    echo " ####"
    # Because SOONG_PARTIAL_COMPILE and SOONG_USE_PARTIAL_COMPILE are set via
    # ANDROID_BUILD_ENVIRONMENT, we only have access to values explicitly set by the user.
    if [[ ${TARGET_BUILD_VARIANT} = eng ]] && [[ $SOONG_USE_PARTIAL_COMPILE == false ]]; then
      echo "${color_info}Partial compilation was disabled due to SOONG_USE_PARTIAL_COMPILE=false"
      echo "See http://go/soong-partial-compile"
    fi
    echo -n "${color_reset}"

    echo
    return $ret
}


function log_tool_invocation()
{
    if [[ -z $ANDROID_TOOL_LOGGER ]]; then
        return
    fi

    LOG_TOOL_TAG=$1
    LOG_START_TIME=$(date +%s.%N)
    trap '
        exit_code=$?;
        # Remove the trap to prevent duplicate log.
        trap - EXIT;
        $ANDROID_TOOL_LOGGER \
                --tool_tag="${LOG_TOOL_TAG}" \
                --start_timestamp="${LOG_START_TIME}" \
                --end_timestamp="$(date +%s.%N)" \
                --tool_args="$*" \
                --exit_code="${exit_code}" \
                ${ANDROID_TOOL_LOGGER_EXTRA_ARGS} \
           > /dev/null 2>&1 &
        exit ${exit_code}
    ' SIGINT SIGTERM SIGQUIT EXIT
}

# Import the build variables supplied as arguments into this shell's environment.
# For absolute variables, prefix the variable name with a '/'. For example:
#    import_build_vars OUT_DIR DIST_DIR /HOST_OUT_EXECUTABLES
# Returns nonzero if the build command failed. Stderr is passed through.
function import_build_vars()
{
    require_top
    local script
    script=$(cd $TOP && build/soong/bin/get_build_vars "$@")
    local ret=$?
    if [ $ret -ne 0 ] ; then
        return $ret
    fi
    eval "$script"
    return $?
}

function cartfs_mount_point() {
  if cartfs --is_running &>/dev/null; then
    # TODO(b/465427340): Read the mount point from the output once CartFS
    # exposes it. CartFS team is aware of this plan and will not change the
    # mount point until we can programmatically read it.
    echo "/google/cartfs/mount"
    return
  fi

  # Fallback to the old findmnt while we wait for all users to update to the
  # latest CartFS version.
  # TODO(b/465427340): Remove this fallback at the same time we start reading
  # the mount point from CartFS.

  # Make sure findmnt is installed.
  if ! command -v findmnt &> /dev/null; then
    return
  fi

  local cartfs_user_id="$(id -u cartfs 2>/dev/null)"

  # To find the main CartFS mount point, filter mounts by cartfs user_id and
  # look for the one where source is just /dev/fuse - that excludes bind mounts
  # that may originate in CartFS.
  local cartfs_mount_point="$(findmnt -t fuse -O "user_id=${cartfs_user_id}" --output "target,source" --raw | grep '/dev/fuse$' | tail -n +1 | awk '{print $1}')"
  # Making sure $cartfs_user_id is not empty since findmnt will return mounts
  # started by root when it is.
  if [[ -n "$cartfs_user_id" ]] && [[ -n "$cartfs_mount_point" ]] && findmnt "$cartfs_mount_point" >/dev/null 2>&1; then
    echo "$cartfs_mount_point"
  fi
}

# Deletes cartfs folders that are mapped to deleted workspaces.
function clean_deleted_workspaces_in_cartfs() {
  local cartfs_mount_point=$(cartfs_mount_point)
  if [[ -n "$cartfs_mount_point" ]]; then
    local folders_list
    folders_list=$(find "$cartfs_mount_point" -maxdepth 1 -type d)
    if [[ -n "$folders_list" ]]; then
      local log_file="${HOME}/.cartfs/cartfs_workspace_deletion.log"
      mkdir -p "$(dirname "${log_file}")"
      while read -r folder; do
        if [[ "$folder" != "$cartfs_mount_point" ]]; then
          local workspace_name="$(basename "${folder}")"
          local workspaces_path="$(dirname "$(dirname "${top}")")"
          local full_path="${workspaces_path}/${workspace_name}"
          if [[ ! -d "${full_path}" ]]; then
            local log_timestamp=$(date +"%Y-%m-%d %H:%M:%S")
            echo "${log_timestamp}: The workspace ${workspace_name} does not exist, deleting ${folder} from cartfs" >> "${log_file}"
            rm -Rf "${folder}" &
          fi
        fi
      done <<< "$folders_list"
    fi
  fi
}

# Configure the output directory of the new workspace in Cartfs to be an
# incremental build by copying the build output of a previous build of the same
# repo and forking the mtimes in Cog.
function setup_cartfs_incremental_build() {
  # Make sure grpc_cli is installed.
  if ! command -v grpc_cli &> /dev/null; then
    return
  fi

  local link_destination=$1
  if [[ -d "$link_destination" ]]; then
    return
  fi

  local cartfs_endpoint="127.0.0.1:65001"
  local cartfs_rpc_copy_directory="cartfs.Cartfs.CopyDirectory"

  # Make sure CartFS is listening on the endpoint and that the CopyDirectory
  # function is available.
  if ! grpc_cli ls ${cartfs_endpoint} ${cartfs_rpc_copy_directory} --channel_creds_type=insecure &> /dev/null; then
    return
  fi

  local cogfsd_endpoint="unix:///google/cog/status/uds/${UID}"
  local cogfsd_rpc_forkmtimes="devtools_srcfs.CogLocalRpcService.ForkMtimes"

  # Make sure Cogfsd is listening on the endpoint and that the ForMtimes
  # function is available.
  if ! grpc_cli ls ${cogfsd_endpoint} ${cogfsd_rpc_forkmtimes} --channel_creds_type=insecure &> /dev/null; then
    return
  fi

  echo "Searching for recent build outputs in CartFS for incremental builds"

  local cartfs_mount_point=$2
  local top=$(gettop)
  local repo="$(basename "${top}")"
  local current_cartfs_folder="$(dirname "${link_destination}")"
  local target_workspace="$(basename "${current_cartfs_folder}")"
  local source_workspace=""
  local copy_from=""
  local folders=""

  folders=$(stat -c "%Y %n" ${cartfs_mount_point}/*/out 2>/dev/null | sort -nr | sed 's/^[0-9]\+ //')
  if [[ -n "${folders}" ]]; then
    while read -r cartfs_out; do
      if [[ "${cartfs_out}" != "${link_destination}" ]]; then
        local workspace_name="$(basename "$(dirname "${cartfs_out}")")"
        local workspace_path="$(dirname "$(dirname "${top}")")"
        local full_path="${workspace_path}/${workspace_name}/${repo}"

        # Make sure the CoG workspace still exists and is of the same repo.
        if [[ ! -d "${full_path}" ]]; then
          continue
        fi

        # Make sure the out directory exists, is not empty, and we can stat it.
        if [[ -d "${cartfs_out}" && -n "$(ls -A "${cartfs_out}")" ]]; then
          copy_from="${cartfs_out}"
          source_workspace="${workspace_name}"
          break
        fi
      fi
    done <<< "$folders"
  fi

  if [[ -n "$copy_from" ]]; then
    echo "Found suitable build output from workspace ${source_workspace}"
    echo "Copying content from $copy_from to $link_destination"
    # Filtering output to only include relevant information.
    local output_filter="connecting to|Rpc succeeded with OK status|Not yet implemented|success|Received trailing metadata from server"
    if ! grpc_cli call ${cogfsd_endpoint} ${cogfsd_rpc_forkmtimes} \
    'source_workspace: "'${source_workspace}'"
     target_workspace: "'${target_workspace}'"' \
      --channel_creds_type=insecure 2>&1 | grep -v -E "${output_filter}"; then
      return 1
    fi
    if ! grpc_cli call ${cartfs_endpoint} ${cartfs_rpc_copy_directory} \
    'from_path: "'${copy_from#$cartfs_mount_point/}'"
     to_path: "'${link_destination#$cartfs_mount_point/}'"' \
      --channel_creds_type=insecure 2>&1 | grep -v -E "${output_filter}"; then
      return 1
    fi
    # Adding a file to track that the workspace is an incremental
    # build from Cartfs. This will be used for metrics.
    echo "${source_workspace}" > "${link_destination}/.cartfs-copied"
    # Don't carry over the leftovers file from previous workspace.
    rm -f "${link_destination}/.leftovers"
  else
    echo "No suitable build outputs matching the same repository found."
    echo "Starting from a fresh build output directory."
  fi
}
