# bitcoin-regtest-box docker image
#

FROM ubuntu:12.04
MAINTAINER Khoi Pham <pckhoi@gmail.com>

# basic dependencies to build headless bitcoind
# https://github.com/freewil/bitcoin/blob/easy-mining/doc/build-unix.md
RUN apt-get update
RUN apt-get install --yes build-essential libssl-dev libboost-all-dev

# install db4.8 provided via the bitcoin PPA
RUN apt-get install --yes python-software-properties
RUN add-apt-repository --yes ppa:bitcoin/bitcoin
RUN apt-get update
RUN apt-get install --yes db4.8

# install wget to download latest bitcoin binary
RUN apt-get install --yes wget

# create a non-root user
RUN adduser --disabled-login --gecos "" tester

# change root password, should still be able to change back to root
RUN echo 'root:abc123' |chpasswd

# run following commands from user's home directory
WORKDIR /home/tester

# download and extract bitcoind version 0.9.2.1
RUN wget https://bitcoin.org/bin/0.9.2.1/bitcoin-0.9.2.1-linux.tar.gz
RUN tar -xvzf bitcoin-0.9.2.1-linux.tar.gz

# install bitcoind
RUN cp bitcoin-0.9.2.1-linux/bin/64/bitcoind /usr/local/bin/bitcoind
RUN cp bitcoin-0.9.2.1-linux/bin/64/bitcoin-cli /usr/local/bin/bitcoin-cli

# copy the testnet-box files into the image
ADD . /home/tester/bitcoin-testnet-box

# make tester user own the bitcoin-testnet-box
RUN chown -R tester:tester /home/tester/bitcoin-testnet-box

# use the tester user when running the image
USER tester

# run commands from inside the testnet-box directory
WORKDIR /home/tester/bitcoin-testnet-box

# expose two rpc ports for the nodes to allow outside container access
EXPOSE 19001 19011
CMD ["/bin/bash"]
