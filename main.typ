#import "@preview/slydst:0.1.4": *

#show: slides.with(
  title: "Bitcoin Test Framework",
  subtitle: "vinteum's study hour",
  date: none,
  authors: ("qlrd - Floresta/Krux contributor",),
  layout: "medium",
  ratio: 4/3,
  title-color: none,
)

#show link: it => {
  set text(blue)
  if type(it.dest) != str {
    it
  }
  else {
    underline(it)
  }
}

== Bitcoin Test Framework

#align(horizon)[
    #definition[
      The functional tests [that] test the RPCs. @avachown2018
    ]
]

== RPC @networkworkingroup2009

#align(horizon)[
  Each *remote procedure call* has two sides: an active client side that makes the call to a server side, which sends back a reply. (...)
   The caller first sends a call message to the
   server process and waits (blocks) for a reply message.  The call
   message includes the procedure's parameters, and the reply message
   includes the procedure's results.  Once the reply message is
   received, the results of the procedure are extracted, and the
   caller's execution is resumed.
]



== Bitcoin Test Framework

#align(horizon)[
    #definition[
      The functional test frameworks uses a version of `python-bitcoinrpc` which can be found here @jgarzik2015. This library allows the test framework to call RPC commands as if they were python functions. @avachown2018
    ]
]

== RPC example with `bitcoin-cli`

#align(horizon)[
  ```bash
  # mannually add a node 
  $> bitcoin-cli -regtest addnode 127.0.0.1:38334 add true
  ```
]

== RPC example with `curl`
#align(horizon)[
  ```bash
  # mannually add a v2transport enabled node 
  $> curl --user youruser:yourpass \
     --data-binary '{"jsonrpc":"1.0","id":"curltest","method":"addnode","params":["127.0.0.1:38334","add", true]}' \
     -H 'content-type: text/plain;' \
     http://127.0.0.1:18443/
  ```
]

== RPC example with `python`
#align(horizon)[
  ```python
  class NetTest(BitcoinTestFramework):
  
    ...
    
    def run_test(self):
        # We need miniwallet to make a transaction
        self.wallet = MiniWallet(self.nodes[0])

        # By default, the test framework sets up an addnode 
        # connection from node 1 --> node0. By connecting 
        # node0 --> node 1, we're left with
        # the two nodes being connected both ways.
        # Topology will look like: node0 <--> node1
        self.connect_nodes(0, 1)
        self.sync_all()
  ``` 
]

== What is a functional test?

#align(horizon)[
  #definition[
    Functional test in general is defined as a test that tests functionalities or features of software from a user’s perspective (...) @jahr2019
  // thinking about it is that nodes that you interact with in the network are also users who are using their own node. You have to look at features from your own perspective but also from the network’s perspective. @jahr2019
  ]
]

== Consequence

#align(horizon)[
  (...) it takes pretty long. In general they take longer than unit tests.
  (...) pay some attention to how you write the tests and how many you write. @jahr2019
]


== The test framework

#align(horizon)[
  #definition[
    This is a collection of files that have helpful functionalities that help you to write a test. @jahr2019 
  ]
]

== The `test/funcional/test_framework/test_framework.py`

#align(horizon)[
  This is the most important file that you are going to use in every test. This implements the BitcoinTestFramework class and every test is a subclass of the BitcoinTestFramework class @jahr2019
]

== When do you add/edit functional tests?

#align(horizon)[
   It is not something where you would add or edit a functional test if you implement something new. It is when you don’t really add something new, when you do a refactoring, you don’t really change any functionality that the user sees or that the user would notice @jahr2019
]


== Where are the files?

#align(horizon + center)[
  https://github.com/bitcoin/bitcoin > test > functional 
]


== Which are the file types?

#align(horizon)[
  (...) you find files that are following a naming scheme @jahr2019:
  
  - example:
    - `test/functional/example_test.py`;
]

== Which are the file types?

#align(horizon)[
  - features (assumevalid, assumeutxo, etc...):
    - `test/functional/feature_*.py`;
    
  - interface (cli, rest, zmq, ...):
    - `test/functional/interface_*.py`;
    
  - mempool:
    - `test/functional/mempool_*.py`;
]


== Which are the file types?

#align(horizon)[
  - mining:
    - `test/functional/mining_*.py`;
  
  - p2p:
    - `test/functional/p2p_*.py`;

  - rpc (getblockcaininfo, getblock, deriveaddresses, etc...):
    - `test/functional/rpc_*.py`;

  - wallet :
    - `test/functional/wallet_*.py`;
]

== Which are the file types?

#align(horizon)[
   There is also a single test that has the prefix `tool_` @jahr2019
]

== Which are the file types?

#align(horizon)[
  - tools (signet miner, utxo to sqlite, etc...):
    - `test/functional/tool_*.py`;
]

== Running functional tests @jahr2019

#align(horizon)[
  - (...) you can run these tests directly like any other Python file by specifying the path.
  
  - (...) you can also run the tests through test harness and that is very helpful if you want to run all the tests in one time, the full functional test suite.

  - (...) you want to do some pattern matching on the names. You want to run all the wallet tests.
]

== Run these tests directly @jahr2019

#align(horizon)[
  Tests come with shebang (`#!/usr/bin/env python3`)
  
  ```bash 
  $> test/functional/feature_rbf.py
  ```
]

== Run the tests through test harness @jahr2019

#align(horizon)[
  ```bash 
  $> test/functional/test_runner.py feature_rbf.py
  ```
]

== Run the tests through test harness @jahr2019

#align(horizon)[
  Run only the tests that starts with the `wallet_` prefix:
  ```bash 
  $> test/functional/test_runner.py test/functional/wallet\*
  ```
]


== BitcoinTestFramework class

#align(horizon)[
  ```python 
class BitcoinTestMetaClass(type):
    """Metaclass for BitcoinTestFramework.

    Ensures that any attempt to register a subclass of 
    `BitcoinTestFramework` adheres to a standard whereby the 
    subclass overrides `set_test_params` and `run_test` but DOES 
    NOT override either `__init__` or `main`. If any of those 
    standards are violated, a ``TypeError`` is raised."""
  ```
]

== BitcoinTestFramework class

#align(horizon)[
  ```python 
class BitcoinTestFramework(metaclass=BitcoinTestMetaClass):
    """Base class for a bitcoin test script.

    Individual bitcoin test scripts should subclass this class 
    and override the set_test_params() and run_test() methods.

    Individual tests can also override the following methods to 
    customize the test setup:

    - add_options()
    - setup_chain()
    - setup_network()
    - setup_nodes()

    The __init__() and main() methods should not be overridden.

    This class also contains various public and private helper methods."""
  ```
]

== Documentation and logs @jahr2019

#align(horizon)[
  You will see:
  - documentation and logs in the test;
  - docstrings at the beginning of every class and every important function;
  - see comments and you will also see these `self.log.info()` outputs.
]

== A new test class @jahr2019

#align(horizon)[
  The two functions that are going to see overriding almost every test is one setting the `test_params()` by overriding `set_test_params()`.
]

== Node calls

#align(horizon)[
  In every test what you are going to see is calls on the nodes:
]

== Node calls: connections

#align(horizon)[
  You will typically have an array of nodes on self and then you will refer to these nodes by just giving them a number but you can also alias them if you want:
  
  ```python 
  self.nodes[0].add_p2p_connection(BaseNode())
  ```
]

== Node calls: mining and control @bitcoincore_setupnode_2014

#align(horizon)[
  These are going to be `regtest` nodes so you can use `regtest` RPC commands like:
  
  ```python
  block_hash = self.generate(self.nodes[0], 1, sync_fun=self.no_op)[0]
  block = self.nodes[0].getblock(blockhash=block_hash, verbosity=0)
  for n in self.nodes:
      n.submitblock(block)
      chain_info = n.getblockchaininfo()
      assert_equal(chain_info["blocks"], 200)
      assert_equal(chain_info["initialblockdownload"], False)
  ```
]

== P2P introspection @jahr2019

#align(horizon)[
  Oftentimes you will have a node where you are testing something on but you want to make sure that first of all the network is synced up to that node or your node has to sync up to the network. Or just the block has been sent, stuff like that. 
]

== P2P introspection: synchronization @jahr2019

#align(horizon)[
  Often you will see functions that are doing a wait for you until everything is synced up. They are going to fail the test if they don’t:

    - `sync_all()`;
    - `sync_blocks()`.
]

== P2P introspection: hooks @jahr2019

#align(horizon)[
  You can also go deeper and subclass the `P2PInterface` class and redefine hooks on this @bitcoincore_p2p_interface_2014. 
]

== P2P introspection: hooks @jahr2019

#align(horizon)[
  ```python 
  def on_message(self, message):
        """Receive message and dispatch message to appropriate
        callback.

        We keep a count of how many of each message type has been 
        received and the most recent message of each type."""
        with p2p_lock:
            try:
                msgtype = message.msgtype.decode('ascii')
                self.message_count[msgtype] += 1
                self.last_message[msgtype] = message
                getattr(self, 'on_' + msgtype)(message)
            except Exception:
                print(
                  "ERROR delivering %s (%s)" % 
                  (repr(message), sys.exc_info()[0])
                )
                raise
  ```
]

== P2P introspection: hooks @jahr2019

#align(horizon)[
  ```python 
    def on_open(self):
        pass

    def on_close(self):
        pass

    def on_addr(self, message): pass
    def on_addrv2(self, message): pass
    def on_block(self, message): pass
    def on_blocktxn(self, message): pass
    def on_cfcheckpt(self, message): pass
    def on_cfheaders(self, message): pass
    def on_cfilter(self, message): pass
    def on_cmpctblock(self, message): pass
    def on_feefilter(self, message): pass
  ```
]

== Example @jahr2019

#align(horizon)[
  #link("https://github.com/bitcoin/bitcoin/blob/master/test/functional/rpc_blockchain.py")[`test/functional/rpc_blockchain.py`]:

  - docstring which is describing what this is actually testing, a bunch of RPCs. 
  - imports. It is very important we don’t do any wildcard imports. 
  - subclass of BitcoinTestFramework and this is overriding the `set_test_params` function.
  - the `run_test` which is the actual test.
]

== Derivations of Bitcoin Test Framework

#align(horizon)[
  - #link("https://github.com/bitcoin-dev-project/warnet")[Warnet]: Run scenarios of network behavior across the network which can be programmed using the Bitcoin Core functional test_framework language.
  - #link("https://github.com/vinteumorg/Floresta/tree/master/tests")[Floresta test framework]: integration tests for Floresta.
]
= Bibliography
== Bibliography
#bibliography("main.bib")
