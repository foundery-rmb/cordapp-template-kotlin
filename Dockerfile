FROM foundery.azurecr.io/foundery/corda:3.2

ARG NODE_PATH

ADD ${NODE_PATH}/cordapps/*.jar /opt/corda/cordapps/
ADD ${NODE_PATH}/node.conf /opt/corda/
ADD ${NODE_PATH}/network-parameters /opt/corda/
ADD ${NODE_PATH}/certificates/* /opt/corda/certificates/
ADD ${NODE_PATH}/additional-node-infos/* /opt/corda/additional-node-infos/

EXPOSE 10002
EXPOSE 10003
EXPOSE 10004

WORKDIR /opt/corda
ENV HOME=/opt/corda
USER corda

