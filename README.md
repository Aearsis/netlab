# Netlab - the BIRD network testing framework

The netlab is lightweight testing framework for the BIRD internet routing
daemon. It is based on linux network namespaces. It aims for simplicity while
developing new features into the BIRD.

## Installation
Clone the netlab into the root of the BIRD repository, or change the
path to BIRD inside the main executable.

## Running
Then, from the BIRDs directory you can run:
```
 $ sudo netlab/netlab
 Welcome to the netlab shell! To get help, write 'help'.
 [netlab] # 
```

## Using
This is a usual bash prompt, you can still use commands you are used to. But there are few more:

```
 [netlab] # help
 You can use following commands:
 help                   Show this help once again
 net_up                 Brings the network virtualization up
 start [nodes...]       Start the nodes

 shell  <node> [cmd]    Executes a shell command in the node's environment, or
                        opens the shell
 client <node> [cmd]    Sends the node a command or opens an interactive client
 dump   <node>          Sends the node a "dump protocols" command
 debug / log <node>     Shows the log for node

 command_all <command>  Sends all nodes a command

 stop [nodes...]        Stop the nodes
 net_down               Brings the network virtualization down

 Netlab can be run either by invoking a command:
         netlab [command] [...]
 or by entering the netlab shell by sourcing it:
         source netlab

 Change the network scheme by changing the variable NETLAB_NETWORK. Do not do it
 while other network is up.
```

There are my current testing networks (`networks/default`) and config files under cfg. The basic workflow is:

```
 [netlab] # net_up
 [netlab] # start
 [r1] [r1n1] [r1n2] [r2] [r2n1] [r2n2] 
 (do some work, recompile BIRD)
 [netlab] # restart
 [r1] [r1n1] [r1n2] [r2] [r2n1] [r2n2] 
 [r1] [r1n1] [r1n2] [r2] [r2n1] [r2n2] 
 [netlab] # log r1
 [netlab] # dump r2
 [netlab] # debug r2
 [netlab] # shell r1 wireshark-gtk &
 (repeat until too sleepy)
 [netlab] # stop
 [r1] [r1n1] [r1n2] [r2] [r2n1] [r2n2] 
 [netlab] # net_down
 [netlab] # exit
```

## Customizing

You can define your own testing network using a simple language (not really
a language, just a few handy functions). Lets take my default as an example:
```
 NET_CFG="$NETLAB_BASE/cfg"
```
The root directory for config files. For every node $N$, a file bird_$N$.conf must be present.
```
 netlab_node r1
```
Run a BIRD node $r1$.
```
 if_dummy r1 d1 10.1.0
```
Adds a dummy interface d1 to the r1's namespace. It will have a 10.1.0.0/24
subnet.
```
 if_veth r1 r2 10.10.1
```
There will be a 10.10.1.0/24 subnet between r1 and r2. It is created with a virtual ethernet pair.
```
 if_bridge  br0 10.3.0.1
 if_plug r1 br0 10.3.0.2
```
Create a bridge in its own namespace, having the subnet /24 inside, and the
bridge will have an address 10.3.0.1.

Then, plug r1 into it with a virtual ethernet pair, where the r1 will have
address 10.3.0.2. It is currently not possible to create two plugs.
```
 nl_netns send
```
Create a network namespace without a BIRD running. For example, to run
a multicast source.
```
 nl_route send 224.0.0.0/4 dev veth-r1n1
```
Add a static route.
```
 netlab_on_up echo "the network is being created"
 netlab_on_down echo "turning off the power"
```
Oh come on. I should not explain these.

## Internals

The network file is included multiple times, but the meaning of the commands is
different. While issuing a command not touching the network, only the
`netlab_node` command does something (fills the internal $NETLAB_NODES). When
starting the network, the commands create and add virtual devices, and when
taking the network down, the commands delete whole namespaces.

This descriptive notation of virtual network is well readable and like it.
