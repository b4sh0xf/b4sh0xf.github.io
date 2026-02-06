```java
package hc.ghupasselongo.java.test01.helpers;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.Base64;

public class Serializer {
    public static String serialize(Object object) {
        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ObjectOutputStream oos     = new ObjectOutputStream(baos);
            
            oos.writeObject(object);

            return Base64.getEncoder().encodeToString(baos.toByteArray());
        } catch (Exception errException) {
            System.out.println(errException);
            return null;
        }
    }

    public static Object unserialize(String encodedObject) {
        try {
            byte[] serializedObject   = Base64.getDecoder().decode(encodedObject);
            ByteArrayInputStream bais = new ByteArrayInputStream(serializedObject);
            ObjectInputStream ois     = new ObjectInputStream(bais);
            
            return ois.readObject(); // <- desserialização the fato
            
        } catch (Exception errorException) {
            System.err.println(errorException);
            return null;
        }
    }

}
```

```java
package hc.ghupasselongo.java.test01.entities;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.Serializable;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class User implements Serializable {
    
    private String name;
    private String role;
    private Integer id;

    @Override // sobrescrita da função que ja existe no core do java
    public String toString() {
        System.out.println("[*] toString() called!");
        return super.toString();
    }

    @Override
    public int hashCode() {
        System.err.println("[*] hashCode() called!");
        return super.hashCode();
    }

    @Override
    public boolean equals(Object object) {
        System.err.println("[*] equals() called!");
        return super.equals(object);
    }

    private void readObject(ObjectInputStream ois) throws IOException, ClassNotFoundException {
        System.out.println("[*] readObject() called!"); // comportamento similar à __wakeup()
        System.out.println(this.name); // retorna null
        ois.defaultReadObject(); // leitura das propriedades do objeto serializado
        System.err.println(this.id); // retorna o id
    }

}
```

```java
package hc.ghupasselongo.java.test01.controllers;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import hc.ghupasselongo.java.test01.dto.ExampleDTO;
import hc.ghupasselongo.java.test01.entities.User;
import hc.ghupasselongo.java.test01.helpers.Serializer;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/")
public class HomeController {
    @GetMapping 
    public String test() {

        User user0 = new User();
        user0.setId(888);
        user0.setName("0xf");
        user0.setRole("dev");

        User user1 = new User();
        user1.setId(777);
        user1.setName("ghu");
        user1.setRole("admin");

        ArrayList<User> userArray = new ArrayList<>();
        userArray.add(user0);
        userArray.add(user1);

        userArray.contains(user1); // implicitamente chama a função equals

        System.err.print(user0);                 // pra triggar a toString()
        Set<User> userList = new HashSet<>();
        userList.add(user1);                     // pra triggar a hashSet()
        System.out.println(user1.equals(user0)); // pra triggar a equals

        return Serializer.serialize(user1);
    }

    @PostMapping
    public String test(@Valid @RequestBody ExampleDTO exampleDTO) {
        String object = exampleDTO.getPayload();              // {"payload":<objeto serializado aq>}
        User user     = (User)Serializer.unserialize(object); // objeto da classe User
        return user.getName();                                // chama a getName desse objeto
    }
}
```

```java
package hc.ghupasselongo.java.test01.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ExampleDTO {
    @NotBlank
    private String payload;
    
}


// uma dto serve para definir a tipagem e a obrigatoriedade de dados.
```