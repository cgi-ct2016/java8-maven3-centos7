# java8-maven3-centos
#

FROM openshift/base-centos7

EXPOSE 8080

ENV JAVA_VERSION=1.8.0 \
   MAVEN_VERSION=3.3.9 \
   PATH=$HOME/.local/bin/:$PATH

LABEL io.k8s.description="Platform for building and running Java8/Maven3 applications" \
      io.k8s.display-name="Java8 Maven3" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,java,java8,maven,maven3,springboot"

RUN INSTALL_PKGS="curl java-$JAVA_VERSION-openjdk java-$JAVA_VERSION-openjdk-devel" && \
   yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
   rpm -V $INSTALL_PKGS && \
   yum clean all -y

RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV JAVA_HOME=/usr/lib/jvm/java \
   MAVEN_HOME=/usr/share/maven

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH.
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
# COPY ./contrib/ /opt/app-root

# In order to drop the root user, we have to make some directories world
# writable as OpenShift default security model is to run the container under
# random UID.
RUN chown -R 1001:0 /opt/app-root && chmod -R og+rwx /opt/app-root

USER 1001

# Set the default CMD to print the usage of the language image.
CMD $STI_SCRIPTS_PATH/usage
