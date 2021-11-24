FROM ubuntu:18.04 AS build

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

RUN apt-get update
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y maven
RUN apt-get install -f libpng16-16
RUN apt-get install software-properties-common -y
RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"

RUN apt-get install -f libjasper1 libjasper-dev
RUN apt-get install -y libjasper1
RUN apt-get install -y libdc1394-22

# install git 
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git

# clone project and install opencv 
RUN git clone https://github.com/barais/TPDockerSampleApp.git

WORKDIR /TPDockerSampleApp 

RUN mvn install:install-file -Dfile=./lib/opencv-3410.jar \
     -DgroupId=org.opencv  -DartifactId=opencv -Dversion=3.4.10 -Dpackaging=jar

RUN mvn package


# recopié 
FROM build

COPY --from=build /TPDockerSampleApp/lib/ubuntuupperthan18/ /app/lib/
COPY --from=build /TPDockerSampleApp/target/fatjar-0.0.1-SNAPSHOT.jar /app/app.jar
COPY --from=build /TPDockerSampleApp/haarcascades /app/haarcascades

RUN apt-get install -y openjdk-8-jre
RUN apt-get install -f libpng16-16
RUN apt-get install -y libjasper1
RUN apt-get install -y libdc1394-22

WORKDIR /app

CMD java -Djava.library.path=lib -jar /app/app.jar     


