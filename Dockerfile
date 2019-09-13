ARG IMAGE_FROM=10.5.1

FROM ifurther/geant4:${IMAGE_FROM}
LABEL maintainer="Further Lin <geant4ro.ot@gmail.com>"

RUN sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1tw.\2/" /etc/apt/sources.list 
	
ENV G4Version="10.05.p01"
ENV shortG4version="10.5.1"
ENV PTSIMVersion="105-001-000-20190725"

ENV G4WKDIR=/app
ENV G4DIR=/app/geant4.${shortG4version}-install
ENV PTSprojectDIRsrc=/src/PTSproject
ENV PTSprojectDIR=/app/PTSproject-install

WORKDIR /app

RUN if [ ! -e ${G4WKDIR}/src ];then mkdir ${G4WKDIR}/src;fi
RUN echo "G4WKDIR is: ${G4WKDIR}"

ADD PTSproject-${PTSIMVersion}.tar.gz /src
#RUN rm -rf PTSproject-${PTSIMVersion}.tar.gz

RUN /bin/bash -c "source $G4WKDIR/entry-point.sh; \
cd $PTSprojectDIRsrc && \
cp script/buildDynamicIAEAMPI.sh . && \
sed -i 's/\..\/\..\/\../\/app/g' ./buildToolkitIAEA.sh && \
sed -i 's/\..\/\..\/\../\/app/g' ./buildToolkitIAEA.sh && \
sed -i 's/^make/make \-j\`grep \-c \^processor\ \/proc\/cpuinfo\`/g' ./buildToolkitIAEA.sh && \
sed -i 's/^make/make \-j\`grep \-c \^processor\ \/proc\/cpuinfo\`/g' ./buildToolkitIAEA.sh && \
sed -i 's/GetSize/GetActiveSize/g' ./PTSapps/DynamicPort/app/src/MyApplication.cc && \
./buildToolkitIAEA.sh &&\
./buildDynamicIAEAMPI.sh &&\
cd $G4DIR &&\
rm -rf $PTSprojectDIRsrc"


RUN ls $G4WKDIR/geant4.${shortG4version}-install
