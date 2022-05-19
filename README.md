**DocNet** (Multi-user **Doc**umentation **Net**work).

DocNet is: 

- **A documentation framework**. It allows the creation and edition of instances of documentations, without putting any kind of restriction on the files and formats users decide to use (text, .md files, pictures, Word Documents, Powerpoints etc...), as well as acting as a search index for not only its own data but also other source of documenation (for instance existing Google Docs).

- Individual pieces of DocNet are organised as a **semantic network**.

- A self validating, conflict free, distributed **file system**. In particular, edits made by one user are distributed to all other users seamlesly. One particularly interesting feature of the DocNet file system is that it is possible to access it as it was at any point in the past, since all its intermediary states are conserved (thereby behaving a bit like a git repository).

DocNet comes with a: 

- **terminal** interface. That said, manipulating collections of files is done the usual way, using the local file system. (There is room for a graphical or web interface in the future.)

DocNet was made for:

- My amazing engineering colleagues at [the Guardian](https://github.com/guardian). 

DocNet was made because:

- I grew sick and tired of the fact that we never invested into a documentation framework that allows new and existing employes to find general engineering documentation, beyond what is related to source code, instead of relying on individual memories and fragment of conversations on Chat.
