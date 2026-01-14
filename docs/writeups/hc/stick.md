![image.png](attachment:be780eff-7b67-4a72-abb7-23a6e5415899:image.png)

---

## vulns: `unrestricted access to sensitive business flows`, `arbitrary file read` e `container escape`

## 1️⃣ recon

- acessando o web server, vemos que se trata de uma aplicação web sobre um projeto de plantio de árvores
    
    ![image.png](attachment:2daa5328-f546-4fb5-97b2-befa8cce6cef:image.png)
    
- criando nosso usuário e fazendo login, temos acesso à dashboard, onde podemos fazer uma doação em dinheiro que será revertida no plantio de árvores
    
    ![image.png](attachment:38157f1e-4412-411e-b62b-3ece625177b6:image.png)
    
- vemos que se plantarmos um total de $1000$ árvores, seremos convidados a fazer parte da administração da plataforma, então vamos fazer uma doação
    
    ![image.png](attachment:cf7d988e-07a1-4b9d-87fe-7936123e13e8:image.png)
    
- todas as doações são registradas na dashboard, e vemos que o status está pendente e que só será confirmada, provavelmente pelo admin, dentro de $24h$
    
    ![image.png](attachment:36083c57-ffe1-4de4-b38b-c8f444f1a2ea:image.png)
    

## 2️⃣ fuzzing

- analisando a request que foi feita, vemos que podemos controlar o valor da doação, o que por si só não é uma vulnerabilidade tão crítica, mas querendo ou não, é um problema de lógica de negócio, pois em teoria, a aplicação só deveria aceitar doações de $10, $50 ou $100
    
    ![image.png](attachment:dc9fe575-de2c-47dd-b390-8c783691293c:image.png)
    
- fazendo essa doação de $10k, temos como pendente a plantação de 1000 árvores (além da primeira doação), logo, temos que descobrir algum jeito de mudar o status da nossa doação
    
    ![image.png](attachment:c7d8e172-2f69-48fb-a956-929535d7a951:image.png)
    
- analisando o código-fonte da dashboard, encontramos um código js interessante
    
    ```jsx
    function updateStatus(id, status) {
        const requestData = {
            id: id,
            status: status
        };
    
        fetch('/donation/' + id, {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(requestData)
        })
        .then(response => response.json())
        .then(data => {
            document.getElementById('statusBadge').textContent = data.status;
            document.getElementById('statusBadge').className = `badge ${
                data.status === 'confirmed' ? 'bg-success' :
                data.status === 'rejected' ? 'bg-danger' : 'bg-warning'
            }`;
            document.getElementById('donationAmount').textContent = data.amount;
            document.getElementById('treesPlanted').textContent = data.trees_planted;
    
            if (data.status !== 'pending') {
                document.getElementById('statusControls').style.display = 'none';
            }
    
            alert('Donation status updated successfully!');
    
            if (data.trees_planted >= 1000) {
                window.location.reload();
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Failed to update donation status.');
        });
    }
    
    ```
    
- com um code-review simples, percebemos que o status das doações é modificado a partir de requests do tipo `PATCH` para a rota `/donation/${id}`, passando via json o `id` da doação e o novo status
- então, se tivermos permissão para fazer esse tipo de request, conseguimos explorar uma falha de `business logic`, pois o nosso usuário terá plantado as $1000$  arvores sem ter o feito (situação análoga: falha no sistema de transferência de um banco, em que um usuário é capaz de transferir para a própria conta, criando dinheiro)
- fazendo a request e supostamente plantando as $1000$ árvores:
    
    ![image.png](attachment:d6e1862c-2df0-4a74-ac6c-0b88c760c598:image.png)
    
- voltando na nossa dashboard, vemos que agora nosso usuário tem as $1000$ árvores plantadas
    
    ![image.png](attachment:ccbdeb92-f54b-4dfc-9bdb-10cd44daadbf:image.png)
    
- fazendo login dnv, agora temos acesso ao painel administrativo
    
    ![image.png](attachment:47eb104e-c1b7-41d8-aa8e-702317648fe0:image.png)
    
- podemos fazer upload de arquivos, e a visualização deles é feita via url, logo, a ideia mais óbvia é tentar fazer upload de uma shell, mas não funcionou, então, podemos testar um arbitrary file read
    
    ![image.png](attachment:bbc06374-3069-4036-9860-5bae838693ca:image.png)
    
- a primeira ideia é sempre tentar dumpar o código fonte da aplicação pra fazer um code review, mas antes disso, é bom ler o `/proc/self/cmdline`, que não estava disponível
- com isso, uma outra alternativa é fazer um fuzzing de arquivos, que fucionou e retornou o arquivo `json`
    
    ![image.png](attachment:c6ba0e48-bc5e-4303-8150-7c3831bcd963:image.png)
    

## 3️⃣ rce

- ao ler esse arquivo, parece ser o output de um comando do docker com credenciais hard-coded, e dps de pensar como iria conseguir rce na máquina, decidi só tentar as credenciais no `ssh` da máquina, e foi
    
    ![image.png](attachment:be5fa8b7-5b97-46c4-910b-421e64b1e514:image.png)
    

## 4️⃣ privesc

- o usuário `bispo` está no grupo do `lxd`, que é um serviço de containerização análogo ao docker, e com isso podemos fazer um privesc bem simples
    
    ![image.png](attachment:073ea722-b904-4d18-962d-26288992618c:image.png)