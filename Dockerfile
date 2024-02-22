# Use an Ubuntu base image
FROM ubuntu:xenial

# Set non-interactive shell to avoid user prompts during build
ENV DEBIAN_FRONTEND noninteractive

# Update the package list
RUN apt-get update \
    # Upgrade the system
    && apt-get -y upgrade \
    # Remove unnecessary packages
    && apt-get autoremove -y \
    # Install required packages
    && apt-get install -y --no-install-recommends software-properties-common git build-essential libuuid1 uuid-dev libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make unzip wget curl \
    # Clean up to reduce image size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Install Lua
RUN wget http://www.lua.org/ftp/lua-5.1.5.tar.gz \
    && tar zxf lua-5.1.5.tar.gz \
    && cd lua-5.1.5 \
    && make linux test \
    && make install \
    && cd .. && rm -rf lua-5.1.5*

# Install LuaRocks
RUN wget https://luarocks.github.io/luarocks/releases/luarocks-2.2.0.tar.gz \
    && tar zxf luarocks-2.2.0.tar.gz \
    && cd luarocks-2.2.0 \
    && ./configure --with-lua-include=/usr/local/include \
    && make build \
    && make install \
    && cd .. && rm -rf luarocks-2.2.0*

RUN apt-get update && apt-get install zlib1g-dev
# Install OpenResty
RUN wget http://openresty.org/download/ngx_openresty-1.7.10.1.tar.gz \
    && tar zxf ngx_openresty-1.7.10.1.tar.gz \
    && cd ngx_openresty-1.7.10.1 \
    && ./configure \
    && make \
    && make install \
    && cd .. && rm -rf ngx_openresty-1.7.10.1*

RUN luarocks install lpeg
RUN luarocks install inspect
RUN luarocks install lua-cjson
RUN luarocks install lua-resty-http
RUN luarocks install busted
RUN luarocks install luacrypto
RUN luarocks install router
RUN luarocks install net-url
RUN luarocks install luacheck
RUN luarocks install yaml
RUN luarocks install luasocket
RUN luarocks install lapis

# Set the working directory
WORKDIR /app

# Expose the port that Lapis runs on
EXPOSE 8088

# Run the Lapis server
CMD ["lapis", "server"]
