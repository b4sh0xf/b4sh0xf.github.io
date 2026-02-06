## 0x00: about serialization and deserialization
- disclaimer: is recommended to have a previous knowledge about oriented-object programming concepts and how implement them in php.
- before we start to lern how do we exploit insecure deserialization in php and how to perform complex object injection, it's necessary understand how php parses serialized data.
- ok, let's start creating a simple class, named `App`, with the properties `activities` `services` `broadcast recievers` and `content providers` and with the methods `onCreate` and `onDestroy`.

    ```php
    <?php

    class App {

            public $version = "7.7.7";

            public function __construct($activity, $service, $broadcastReciever, $contentProvider) {
                    $this->activity          = $activity;
                    $this->service           = $service;
                    $this->broadcastReciever = $broadcastReciever;
                    $this->contentProvider   = $contentProvider;
            }

            public function onCreate($activity) {
                    echo "[*] activity ${activity} started!\n";
            }

            public function onDestroy($activity, $service) {
                    echo "[*] activity ${activity} and service ${service} stopped!\n";
            }

    }

    $app = new App("MainActivity", "musicService", "broad", "sqlite3");
    echo "[*] app is in version " . $app->version . "\n";
    $app->onCreate("MainActivity");
    echo "[*] app is using " . $app->contentProvider . "\n";
    $app->onDestroy("MainActivity", "musicService");

    echo serialize($app) . "\n";
    ```
- very simple, right? let's see the output:

    ```bash
    [*] app is in version 7.7.7
    [*] activity MainActivity started!
    [*] app is using sqlite3
    [*] activity MainActivity and service musicService stopped!
    O:3:"App":5:{s:7:"version";s:5:"7.7.7";s:8:"activity";s:12:"MainActivity";s:7:"service";s:12:"musicService";s:17:"broadcastReciever";s:5:"broad";s:15:"contentProvider";s:7:"sqlite3";}
    ```

- as we can see, this php object are reasonably easy to read and understand, be cause all his properties and methods are public, but, in large and complex php applications, normally the public methods and attributes turns into private or protected to organize the code hierarchy. when this occurs, the serialized objects are generated with null bytes.
- let's write another simple code, but with all properties setted to private.

    ```php
    <?php

    class App {

            private $activity          = "MainActivity";
            private $service           = "musicService";
            private $broadcastReciever = "broad";
            private $contentProvider   = "sqlite3";

    }

    echo serialize(new App);
    ```
- now, let's turn all of them public and analye the differences between both serialized objects in a hexadecimal editor

    ```
    ➜  ~ php index.php | xxd
    00000000: 4f3a 333a 2241 7070 223a 343a 7b73 3a31  O:3:"App":4:{s:1
    00000010: 333a 2200 4170 7000 6163 7469 7669 7479  3:".App.activity
    00000020: 223b 733a 3132 3a22 4d61 696e 4163 7469  ";s:12:"MainActi
    00000030: 7669 7479 223b 733a 3132 3a22 0041 7070  vity";s:12:".App
    00000040: 0073 6572 7669 6365 223b 733a 3132 3a22  .service";s:12:"
    00000050: 6d75 7369 6353 6572 7669 6365 223b 733a  musicService";s:
    00000060: 3232 3a22 0041 7070 0062 726f 6164 6361  22:".App.broadca
    00000070: 7374 5265 6369 6576 6572 223b 733a 353a  stReciever";s:5:
    00000080: 2262 726f 6164 223b 733a 3230 3a22 0041  "broad";s:20:".A
    00000090: 7070 0063 6f6e 7465 6e74 5072 6f76 6964  pp.contentProvid
    000000a0: 6572 223b 733a 373a 2273 716c 6974 6533  er";s:7:"sqlite3
    000000b0: 223b 7d                                  ";}

    ➜  ~ php index.php | xxd
    00000000: 4f3a 333a 2241 7070 223a 343a 7b73 3a38  O:3:"App":4:{s:8
    00000010: 3a22 6163 7469 7669 7479 223b 733a 3132  :"activity";s:12
    00000020: 3a22 4d61 696e 4163 7469 7669 7479 223b  :"MainActivity";
    00000030: 733a 373a 2273 6572 7669 6365 223b 733a  s:7:"service";s:
    00000040: 3132 3a22 6d75 7369 6353 6572 7669 6365  12:"musicService
    00000050: 223b 733a 3137 3a22 6272 6f61 6463 6173  ";s:17:"broadcas
    00000060: 7452 6563 6965 7665 7222 3b73 3a35 3a22  tReciever";s:5:"
    00000070: 6272 6f61 6422 3b73 3a31 353a 2263 6f6e  broad";s:15:"con
    00000080: 7465 6e74 5072 6f76 6964 6572 223b 733a  tentProvider";s:
    00000090: 373a 2273 716c 6974 6533 223b 7d         7:"sqlite3";}
    ```
- can you spot the null bytes at the first object? if you dont, just run these commands on your local machine.
- it's important to know this, principally when we are using third-party gadgets to exploit insecure deserialization on laravel applications, for example
- now, let's see how deserialization works. we will reuse the first code and add these line at the end: `var_dump(unserialize($serialized))`. output:

    ```bash
    object(App)#2 (5) {
        ["version"]=>
        string(5) "7.7.7"
        ["activity"]=>
        string(12) "MainActivity"
        ["service"]=>
        string(12) "musicService"
        ["broadcastReciever"]=>
        string(5) "broad"
        ["contentProvider"]=>
        string(7) "sqlite3"
    }
    ```
- obviously, `unserialize()` returns an object, so we can manipulate your properties with the `->` operators. this trick is useful to manipulate objects without write to them manually.

## 0x01: about magic methods
- php magic methods are special functions that are called when specific events occurs on the flow of an php application, things like the deserialization of an object, comparsions, objects parsed into echoes, etc. in this section, we will talk about the following methods `__construct()`, `__destruct()`, `__wakeup()`.
- let's start with `__construct()`. this method is called when a class is instantiated, being commonly used to define the properties of one class.
    ```php
    <?php

    class User {

        public $name;
        public $pass;

        public function __construct($name, $pass) {
            $this->name = $name;
            $this->pass = $pass;
        }
    
    }
    ```
- now, we will talk about the two main magic methods that we search for at a code review, `__destruct()` and `__wakeup()`. these magic methods are special because they're certainly will be called on the application flow. `__destruct()` is called at the end of a class code execution and `__wakeup()` is called when an object are unserialized.
- there exists so many others php magic methods that can be useful to develop insecure deserialization gadgets. for more information, check the cheatsheet below or read the [docs](https://www.php.net/manual/en/language.oop5.magic.php)
    ```
    - __invoke():   called automatically when uma property is called as a function
    - __toString(): called when an object is echoed or strings are compared
    - __call():     called automatically when a method that no exists in the class is called.
    - __get():      called automatically when a property that no exists in the class is called.
    - __set():      called automatically when its a write attempt to a property that don't exist.
    ```

# 0x02: vulnerable application
- let's build from scratch a simple php api to exploit unsafe deserialization.

```php
<?php

namespace TestApi;

class Router {

    protected $routes = [];

    public function create($method, $uri, $callback) {
        $this->routes[$method][$uri] = $callback;
    }

    public function init() {

        header('Content-Type: application/json');

        $httpMethod = $_SERVER['REQUEST_METHOD'];

        if (isset($this->routes[$httpMethod])) {
            foreach($this->routes[$httpMethod] as $uri => $callback)
            if ($uri === $_SERVER['REQUEST_URI']) {
                return $callback();
            }
        }

        http_response_code(404);
        return;
    }

}
```

```php
<?php

namespace TestApi;

class MainController {

    public function start() {
        $router = new Router();

        $router->create("GET", "/", function() {
            http_response_code(200);
            echo json_encode(["sucess" => "true"]);
            return;
        });

        $router->create("POST", "/unserialize", function() {
            $data = file_get_contents("php://input");
            $json = json_decode($data, true);

            if (isset($json['object'])) {
                $b64 = $json['object'];
                $payload = base64_decode($b64);
                $object = unserialize($payload);
                echo var_dump($object->user);
            } else {
                http_response_code(500);
                echo json_encode(["sucess" => "false"]);
            }
        });

        $router->init();

    }

}
```

```php
<?php

namespace TestApi;

class Logger {

    public $user;
    public $logFile;

    public function __wakeup() {
        system("echo user " . $this->user . " called /unserialize route > " . $this->logFile);
    }

}
```

```php
<?php

use TestApi\MainController;
include __DIR__ . '/../vendor/autoload.php';

$app = new MainController();
$app->start();
```

```json
{
    "autoload": {
        "psr-4": {"TestApi\\": "app/"}
    }
}

```