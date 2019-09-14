ARG IMAGE_FROM=10.5.1-g4mpi

FROM ifurther/geant4:${IMAGE_FROM}
LABEL maintainer="Further Lin <55025025+ifurther@users.noreply.github.com>"

RUN sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1tw.\2/" /etc/apt/sources.list 
	
ENV G4Version="10.05.p01"
ENV shortG4version="10.5.1"
ENV PTSIMVersion="105-001-000-20190725"

ENV G4WKDIR=/app
ENV G4DIR=/app/geant4.${shortG4version}-install
ENV PTSprojectDIRsrc=/src/PTSproject
ENV PTSprojectDIRbud=/src/PTSproject-build
ENV PTSprojectDIR=/app/PTSproject-install

WORKDIR /app
ENV SoftwareSRC=/src

RUN if [ ! -e ${G4WKDIR}/src ];then mkdir ${G4WKDIR}/src;fi
RUN echo "G4WKDIR is: ${G4WKDIR}"

ADD PTSproject-${PTSIMVersion}.tar.gz /src
#RUN wget https://wiki.kek.jp/download/attachments/5343876/PTSproject-105-001-000-20190725.tar.gz?version=2&modificationDate=1564700831891&api=v2 | \
#tar xf PTSproject-${PTSIMVersion}.tar.gz -C /src|rm -rf PTSproject-${PTSIMVersion}.tar.gz

RUN wget https://root.cern/download/root_v6.18.04.Linux-ubuntu18-x86_64-gcc7.4.tar.gz && \
tar xf root_v6.18.04.Linux-ubuntu18-x86_64-gcc7.4.tar.gz -C /app &&rm -rf root_v6.18.04.Linux-ubuntu18-x86_64-gcc7.4.tar.gz

RUN ls /app

RUN rm $G4WKDIR/entry-point.sh

RUN echo -e '\n\
#!/bin/bash\n\
set -e \n\
\n\
source $G4DIR/bin/geant4.sh\n\
source $G4DIR/share/Geant4-${shortG4version}/geant4make/geant4make.sh \n\
source $G4WKDIR/root/bin/thisroot.sh \n\
\n\
exec "$@" \n'\
>$G4WKDIR/entry-point.sh

RUN chmod +x $G4WKDIR/entry-point.sh

RUN /bin/bash -c "source $G4WKDIR/entry-point.sh; \
cd $PTSprojectDIRsrc && \
cp script/buildDynamicIAEAMPI.sh . && \
sed -i 's/\..\/\..\/PTSproject-install/\/app\/PTSproject-install/g' ./buildToolkitIAEA.sh && \
sed -i 's/\..\/\..\/\..\/PTSproject-install/\/app\/PTSproject-install/g' ./buildDynamicIAEAMPI.sh && \
sed -i 's/^make/make \-j\`grep \-c \^processor\ \/proc\/cpuinfo\`/g' ./buildToolkitIAEA.sh && \
sed -i 's/^make/make \-j\`grep \-c \^processor\ \/proc\/cpuinfo\`/g' ./buildDynamicIAEAMPI.sh && \
sed -i 's/GetSize/GetActiveSize/g' ./PTSapps/DynamicPort/app/src/MyApplication.cc && \
./buildToolkitIAEA.sh &&\
./buildDynamicIAEAMPI.sh &&\
cd $G4DIR &&\
rm -rf $PTSprojectDIRbud"


RUN ls $G4WKDIR/geant4.${shortG4version}-install

RUN ls $PTSprojectDIR

#ENTRYPOINT ["/app/entry-point.sh"]
#CMD [ "/bin/bash" ]
