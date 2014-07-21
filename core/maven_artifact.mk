#
# Copyright (C) 2014 Cyanogen, Inc.
#

ifeq ($(strip $(LOCAL_MAVEN_ARTIFACT)),)
  $(error LOCAL_MAVEN_ARTIFACT not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_GROUPID)),)
  $(error LOCAL_MAVEN_GROUPID not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_VERSION)),)
  $(error LOCAL_MAVEN_VERSION not defined.)
endif
ifeq ($(strip $(LOCAL_MAVEN_PACKAGING)),)
  LOCAL_MAVEN_PACKAGING := jar
 endif

LOCAL_UNINSTALLABLE_MODULE := true
LOCAL_MODULE_CLASS := MAVEN_ARTIFACTS

include $(BUILD_SYSTEM)/base_rules.mk

dummy_pom_data := <?xml version="1.0" encoding="UTF-8"?><project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd"><modelVersion>4.0.0</modelVersion><groupId>com.cyanogen.build</groupId><artifactId>$(strip $(LOCAL_MODULE))</artifactId><version>0.0.0-SNAPSHOT</version><dependencies><dependency><groupId>$(strip $(LOCAL_MAVEN_GROUPID))</groupId><artifactId>$(strip $(LOCAL_MAVEN_ARTIFACT))</artifactId><version>$(strip $(LOCAL_MAVEN_VERSION))</version><type>$(strip $(LOCAL_MAVEN_PACKAGING))</type></dependency></dependencies><build><plugins><plugin><groupId>org.apache.maven.plugins</groupId><artifactId>maven-assembly-plugin</artifactId><version>2.4</version><executions><execution><phase>package</phase><goals><goal>single</goal></goals></execution></executions><configuration><descriptorRefs><descriptorRef>jar-with-dependencies</descriptorRef></descriptorRefs><finalName>javalib</finalName><appendAssemblyId>false</appendAssemblyId><outputDirectory>$(intermediates)</outputDirectory></configuration></plugin></plugins></build></project>

dummy_pom := $(intermediates)/pom.xml

$(dummy_pom): $(LOCAL_PATH)/Android.mk
	@mkdir -p $(dir $(dummy_pom))
	@echo '$(dummy_pom_data)' > $(dummy_pom)

$(intermediates)/javalib.jar: $(dummy_pom)
	@mvn -f $(dummy_pom) clean package

$(LOCAL_BUILT_MODULE): $(intermediates)/javalib.jar
