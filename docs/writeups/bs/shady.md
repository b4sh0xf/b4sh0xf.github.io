<div style="background: #161b22; border: 1px solid #30363d; border-left: 8px solid #238636; border-radius: 10px; padding: 20px; margin: 20px 0; font-family: monospace;">
<h2><b>daily challenge: 16/01/26</h2>
    <ul style="list-style: none; padding: 0; margin: 0; font-size: 1.2em; color: #8b949e;">
        <li>🟢 <b>difficulty:</b> <span style="color: #3fb950;">easy</span></li>
        <li>⚡ <b>xp earned:</b> <span style="color: #d29922;">10</span></li>
        <li>📂 <b>categories:</b> <code>api</code>
        <li>🛠️ <b>vulns:</b> <code>broken function level authorization (bfla)</code>
    </ul>
</div>

## 0x00: recon
- we can start registering our user to this trading webapp

    ![register](image-10.png)

- our account starts with 1k euros (i wish that isn't a ctf.) and we can buy/sell digital stocks, exchange money between currencies and all our actions are registered.

    ![stocks](image-11.png)

## 0x01: show me the flag!
- after testing some business logic vulns, we can perform a code review in the `.js` files

    ![debugger](image-12.png)

- when we try to access these admin routes, for my surprise, all of them works! this is an broken function level authorization, when a common user can perform high-privillege actions in the application. in this case, a common trader can see all the trades ever made.

    ![bfla](image-13.png)

- continuing our code review, we can see there exists an `/api/admin/flag` endpoint and by the logic (the vuln, lol), we can take the flag.

    ![flag](image-14.png)