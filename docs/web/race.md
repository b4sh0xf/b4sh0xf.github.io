# **race condition**

## 0x00: what is race condition?
- race condition it's a vulnerability that "raised" in late 10's and occurs due the bad management of concurrent requests by a web application. this kind of vulnerability it's hard to exploit, requiring an thorough analysis of the application's behavior, and, on depend of the case, may be extremely dangerous by the chaining with another vulnerabilities.
- basically, a race condition occurs when the system's behavior is dependent on the sequence or timing of other uncontrollable events, leading to unexpected or inconsistent results.
- let's think on a practical example. take an e-commerce webapp, who implemented a promotional coupon on all of your products, that give to the clients 30% of discount and obviously, can only be used one time. imagine that the logic implemented on the back-end it's something like this:
    ```php
    public function checkCoupon() {

        $used = false;

        if($checkout) {
            $used = true;
        }

    }
    ```
- imagine that one user makes two concomitant requests, so fast that they are done before checkout is completed. with this, he can apply the coupon two times, causing a business-logic problem that in large scale, allow an attacker take products for free.
- to a better understanding, check this scheme by [portswigger](https://portswigger.net/web-security/race-conditions)

    ![portswigger scheme](image.png)

## 0x01: about concurrency
- 
- to talk about concurrency, we will write some code in go, because this language is good to examplify that concept

## 0x02: race condition in go

## 0x03: refs.