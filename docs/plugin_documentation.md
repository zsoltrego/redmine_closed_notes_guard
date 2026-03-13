# Closed Notes Guard plugin

## Általános adatok

Plugin neve: Closed Notes Guard  
Plugin azonosító: closed_notes_guard  
Repository: https://github.com/zsoltrego/closed_notes_guard  
Készítő: Szabó-Pap Zsolt  
Redmine kompatibilitás: 6.x  

## Plugin célja

A plugin megakadályozza, hogy lezárt hibajegyekhez új megjegyzések kerüljenek hozzáadásra vagy a meglévő megjegyzések módosításra kerüljenek.

Ez szerepkör alapú szabályozással történik.

## Funkcionális működés

A plugin ellenőrzi:

- az issue státuszát
- a felhasználó szerepkörét

Ha az issue zárt és a felhasználó szerepköre tiltott, akkor:

- új megjegyzés hozzáadása blokkolásra kerül
- meglévő megjegyzés módosítása blokkolásra kerül

## Használt Redmine komponensek

- Issue modell
- Journal kezelés
- Controller hook

## Adatkezelés

A plugin nem hoz létre új adatbázis táblát.

A működés kizárólag a Redmine meglévő adatait használja.

## Biztonsági hatás

A plugin:

- nem módosít autentikációt
- nem kezel jelszavakat
- nem kommunikál külső API-val
- nem tárol személyes adatot

## Telepítés

```sh
sudo su - redmine
git clone https://github.com/zsoltrego/closed_notes_guard.git plugins/closed_notes_guard
```

Migráció (ha van):

```sh
# bundle config set --local without 'development test'
bundle install
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

Redmine restart szükséges.

```sh
touch tmp/restart.txt
```

## Eltávolítás

Plugin könyvtár törlése és Redmine restart.

```sh
rm -rf plugins/closed_notes_guard
touch tmp/restart.txt
```

## Verziókövetés

A plugin Git repository-ban kerül verziókezelésre.
