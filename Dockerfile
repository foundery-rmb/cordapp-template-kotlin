FROM foundery.azurecr.io/foundery/corda:3.2

ARG NODE_PATH

ADD ${NODE_PATH}/cordapps/*.jar /opt/corda/cordapps/

EXPOSE 10002
EXPOSE 10003
EXPOSE 10004

WORKDIR /opt/corda
ENV HOME=/opt/corda
USER corda

