# this file is used to test this repo on linux
FROM node:latest

# download and build the example
RUN git clone https://github.com/llimllib/node-esbuild-executable.git && \
    cd node-esbuild-executable && \
    make 

# switch to the dist dir
WORKDIR /node-esbuild-executable/dist

# run the program. It should output "10"
CMD ./sum 1 2 3 4

