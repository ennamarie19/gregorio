#Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

##Install Build Dependencies
RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential git autoconf libltdl7-dev flex bison fontforge python-pygments texlive-full

##ADD source code to the build stage
WORKDIR /
ADD https://api.github.com/repos/ennamarie19/gregorio/git/refs/heads/mayhem-tutorial version.json
RUN git clone -b mayhem-tutorial https://github.com/ennamarie19/gregorio.git
WORKDIR /gregorio

##Build
RUN mkdir -p build
RUN ./build.sh --prefix=/gregorio/build --jobs=$(nproc) || true

##Prepare all library dependencies for copy
RUN mkdir /deps
RUN cp `ldd ./src/gregorio-6* | grep so | sed -e '/^[^\t]/ d' | sed -e 's/\t//' | sed -e 's/.*=..//' | sed -e 's/ (0.*)//' | sort | uniq` /deps 2>/dev/null || : 

FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /gregorio/src/gregorio-6* /gregorio
COPY --from=builder /deps /usr/lib
#copy from deps on old system to usrLib on new system

CMD ["/gregorio", "--stdin", "=--stdout"]

