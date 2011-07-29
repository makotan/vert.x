# Copyright 2002-2011 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use
# this file except in compliance with the License. You may obtain a copy of the
# License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

include Java
require "buffer"

module Net
  class Server
    class ConnectCallback < org.nodex.core.net.NetConnectHandler

      def initialize(connect_block)
        super()
        @connect_block = connect_block
      end

      def onConnect(java_socket)
        sock = Socket.new(java_socket)
        @connect_block.call(sock)
      end
    end

    #Can take either a proc or a block
    def Server.create_server(proc = nil, &connect_block)
      connect_block = proc if proc
      Server.new(connect_block)
    end

    def initialize(connect_block)
      super()
      @java_server = org.nodex.core.net.NetServer.createServer(ConnectCallback.new(connect_block))
    end

    def listen(port, host = "0.0.0.0")
      @java_server.listen(port, host)
      self
    end

    def stop
      @java_server.stop
    end

    private :initialize
  end

  class Client
    class ConnectCallback < org.nodex.core.net.NetConnectHandler

      def initialize(connect_block)
        super()
        @connect_block = connect_block
      end

      def onConnect(java_socket)
        sock = Socket.new(java_socket)
        @connect_block.call(sock)
      end
    end

    def Client.create_client
      Client.new
    end

    #Can take either a proc or a block
    def connect(port, host = "localhost", proc = nil, &connect_block)
      connect_block = proc if proc
      @java_client.connect(port, host, ConnectCallback.new(connect_block))
    end

    def initialize
      super()
      @java_client = org.nodex.core.net.NetClient.createClient;
    end

    private :initialize
  end

  class Socket
    @data_block = nil

    class DataCallback < org.nodex.core.buffer.DataHandler
      def initialize(data_block)
        super()
        @data_block = data_block
      end

      def onData(java_buffer)
        buf = Buffer.new(java_buffer)
        @data_block.call(buf)
      end
    end

    def initialize(java_socket)
      super()
      @java_socket = java_socket
    end

    def write(data)
      @java_socket.write(data._to_java_buffer)
    end

    #Can take either a proc or a block
    def data(proc = nil, &data_block)
      data_block = proc if proc
      @java_socket.data(DataCallback.new(data_block))
    end
  end
end

