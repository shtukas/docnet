### Overal architecture diagram

![](pictures/1619949344.jpg)

### The Datablobs repository and the Data Manager 

The Data Manager is the subsystem that implement the logic of synchronisations between users data stores. It is descibed in details in [Data Manager](Data-Manager.md).

### The Sync Protocol

(To be written)

### The Object Manager

The Object Manager (and its dedicated storage, the Object Store) is where the live objects of the DocNet ecosystem live. In some ways, the Object Store is a projection of the Data Store's object subset.

Details about the Objects and their schema can be found in the [Data Schema](Data-Schema.md).

### The User Interface

The last two primary sub systems are the User Interface, currently a terminal interface and the File System Interface, which implements the way DocNet objects present themselves to the user in a read-only or read-write fashion.

### A note of storage

The reason objects carry a type is because all objects of the DocNet universe are ultimately essentially stored in the same repository as flat files. When we reconstruct the DocNet data from stratch, the type indicates which object it is. We would not have this problem if, say, objects of different types were stored in different tables of a SQL database. In this latter case, the name of the table itself determines the nature of the data it contains. One interesting and important side effect of our conventions is that we can add new types without any change in our storage. And we can decommission types also seemlessly. 

One question the reader may have is "Why is the DocNet storage so.... primitive, and doesn't make use of more moderns solution like a database or something ?" The reason is simple, had DocNet been single user, this would be the case. Instead, every detail of the storage conventions exists because we have a multi users system where we want the entire data collection to essentially be an immutable append only self validating repository of content addressed blobs. This makes data synchronisation between instances conceptually far more simple, and easily conflict free without any more efforts.

When it comes to the Data Store, DocNet and git have a lot in common, but there is an important difference: there are no merge conflicts in DocNet. (There can be conflicts, for instance if two users edit the same file at the same time on different local Data Stores, but the resulting conflicts are transparent to the users and detected and resolved differently.)
