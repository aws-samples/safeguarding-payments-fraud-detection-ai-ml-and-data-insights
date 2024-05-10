# Usage
#
# To build image - 
# finch build  -t fraud-app .   
# OR 
# docker build  -t fraud-app .

# To Run
# finch run -it --rm fraud-app 
# OR
# docker run -it --rm fraud-app 

# Build stage
#
FROM maven AS build
ENV HOME=/usr/app
RUN mkdir -p $HOME
WORKDIR $HOME
ADD . $HOME
RUN --mount=type=cache,target=/root/.m2 mvn -f $HOME/pom.xml clean compile assembly:single

#
# Package stage
#
FROM public.ecr.aws/amazoncorretto/amazoncorretto:22-headless
ARG JAR_FILE=/usr/app/target/*.jar
COPY --from=build $JAR_FILE /app/runner.jar
RUN mkdir /root/.aws
ADD credentials /root/.aws
EXPOSE 8080
#ENTRYPOINT java -jar /app/runner.jar