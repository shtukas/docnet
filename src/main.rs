use std::fs;
use std::io;
use std::path::PathBuf;
use std::process::exit;
use std::str::FromStr;
use std::path::Path;
use std::fs::{DirBuilder};
use std::env;

//use serde::{Deserialize, Serialize};
use serde_json::{Value as JSONValue};

use rusqlite::MappedRows;
use rusqlite::NO_PARAMS;
use rusqlite::{params, Connection, Error};

//#[derive(Serialize, Deserialize)]
#[derive(Debug)]
struct LibrarianObject {
    uuid: String,
    raw_object: JSONValue
}

fn string_to_json_value(str: &String) -> JSONValue {
    serde_json::from_str(str).expect("error during JSON deserialisation")
}

fn get_librarian_objects(conn: &Connection) -> Result<Vec<LibrarianObject>, Error> {
    let mut stmt = conn.prepare("SELECT _objectuuid_, _object_ FROM _objects_")?;
    let rows = stmt.query_map(NO_PARAMS, |row| {
        let uuid: String  = row.get(0).unwrap();
        let raw_string: String = row.get(1).unwrap();
        Ok((uuid, raw_string))
    })?;
    
    let mut objects = Vec::new();
    for element in rows {
        let tuple = element.unwrap();
        objects.push(
            LibrarianObject{
                uuid: tuple.0,
                raw_object: string_to_json_value(&tuple.1)
            }
        );
    }
    Ok(objects)
}

fn example_of_sqlite_database_use() -> Result<(), Error> {
    let conn = Connection::open("/Users/pascal/Galaxy/DataBank/Stargate/objects-store.sqlite3")?;
    let objects = get_librarian_objects(&conn).unwrap();
    for object in objects {
        println!("uuid from database: {}, {:?}", object.uuid, object.raw_object)
    }
    Ok(())
}

// This function checks that the user's docnet folder exists and if it doesn't
// proposes to create it. Returns a boolean indicating if the directory exists or not.
fn ensure_docnet_folder() -> bool {
    let path = "/Users/pascal/.docnet"; // TODO: search for the user's home directory
    let exists = Path::new(path).exists();
    if !exists && ask_question_answer_as_boolean("The .docnet data folder doesn't exists, going to create it").unwrap() {
        println!("You have chosen to create the directory");
        fs::DirBuilder::new().create(path).unwrap();
    }
    Path::new(path).exists()
}

fn ask_question_answer_as_boolean(question: &str) -> Result<bool, std::io::Error> {
    println!("{} (yes, no) : ", question);
    let mut input = String::new();
    io::stdin().read_line(&mut input)?;
    Ok(input.trim() == "yes")
}

fn main() -> io::Result<()> {
    println!("Welcome to DotNet");
    if !ensure_docnet_folder() {
        println!("Could not find or create the docnet folder. Aborting.");
        exit(0);
    }
    Ok(())
}
