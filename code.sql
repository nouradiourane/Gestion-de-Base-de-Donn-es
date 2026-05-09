-- Nettoyage des différentes créations

-- Vues
drop view if exists max_spationaute_pays;
drop view if exists nb_spationaute_pays;
drop view if exists spationaute_pays;
drop view if exists nb_missions_pays;
drop view if exists spationaute_fr;

-- Tables (ordre inverse de création)
drop table if exists participe;
drop table if exists mission;
drop table if exists spationaute;
drop table if exists pays;

-- Séquences
drop sequence numero;

-- 1

create sequence numero minvalue 101;

create table pays(
   nom varchar(30) primary key,
   population float,
   superficie float);

\d pays

create table spationaute(
   nom varchar(50),
   prenom varchar(50),
   annaiss integer,
   nomp varchar(30) references pays on update cascade,
   metier varchar(30) default 'militaire',
   primary key(nom,prenom));

\d spationaute

create table mission(
   num integer primary key,
   nom varchar(20),
   nomp varchar(30) references pays on update cascade,
   annee integer,
   duree integer);

\d mission

create table participe(
   nummiss integer references mission on update cascade,
   nomsp varchar(50),
   prenomsp varchar(50),
   role varchar(30),
   constraint lerole check (role in ('commandant', 'ingénieur de vol 1', 'ingénieur de vol 2')),
   foreign key(nomsp,prenomsp) references spationaute on update cascade,
   primary key(nummiss,nomsp,prenomsp));

\d participe

-- 2

insert into pays values
('France',68,672),
('Russie',146.1,17234);

insert into spationaute values
('Pesquet','Thomas',1978,'France','ingénieur aéronautique');

insert into mission values
(nextval('numero'),'Soyouz MS-03','Russie',2016,NULL);

insert into participe values
(101,'Pesquet','Thomas','ingénieur de vol 2');

select * from pays;
select * from spationaute;
select * from mission;
select * from participe;

-- 3

update mission
set duree=196
where num=101;

select * from mission;

-- 4

alter table participe
drop constraint lerole;

alter table participe
add constraint lerole check (role in ('commandant', 'ingénieur de vol 1', 'ingénieur de vol 2', 'touriste spatial'));

\d participe

select * from participe;

-- 5

insert into pays(nom,population) values
('États-Unis',331.5);

insert into spationaute(nom,prenom,annaiss,nomp) values
('Armstrong','Neil',1930,'États-Unis');

insert into mission values
(nextval('numero'),'Apollo 11','États-Unis',1969,8);

insert into participe
select num, 'Armstrong', 'Neil', 'commandant'
from mission
where nom='Apollo 11';

select * from pays;
select * from spationaute;
select * from mission;
select * from participe;

-- 6

insert into spationaute(nom,prenom,nomp)
select 'Haigneré', 'Claudie', nom
from pays
where population=68;

select * from spationaute;

/* pose problème si le select retourne plusieurs n-uplets
car, dans ce cas, ça viole la contrainte de clé primaire
sur spationaute */

-- 7

delete from mission
where nom='Soyouz MS-03';

select * from mission;

/* la suppression du n-uplet n'est pas effectuée car
le numéro de mission de Soyouz MS-03 est utilisé dans
la table participe et on veut interdire la suppression
des valeurs référencées dans d'autres tables*/

-- 8

update mission
set num=1
where nom='Apollo 11';

select * from mission;
select * from participe;

/* Le numéro de mission est modifié et il l'est aussi
dans la table participe.
C'est normal puisqu'on devait autoriser les
mise à jour en cascade.*/

-- pour tester les vues

insert into spationaute values
('Gromiko','Lech',NULL,'Russie'),
('Gagarine','Youri',NULL,'Russie');
insert into participe values
(101,'Gromiko','Lech','commandant'),
(101,'Gagarine','Youri',NULL);


select * from spationaute;
select * from participe;

-- 9

create view spationaute_fr as
select nom, prenom, annaiss
from spationaute
where nomp='France';

select * from spationaute_fr;

-- 10

create view nb_missions_pays as
select nomp, count(num)
from mission
group by nomp;

/*create view nb_missions_pays as
select nomp, count(num) as "nb missions"
from mission
group by nomp;*/

select * from nb_missions_pays;

-- 11

create view spationaute_pays as
select s.nom,prenom,m.nomp
from spationaute s
   join participe on s.nom=nomsp and prenom=prenomsp
   join mission m on nummiss=m.num
where s.nomp=m.nomp;

select * from spationaute_pays;

-- 12

create view nb_spationaute_pays as
select nomp, count(nom) as "nb spationautes"
from spationaute_pays
group by nomp;

/*create view nb_spationaute_pays as
select nomp, count(nom)
from spationaute_pays
group by nomp;*/

select * from nb_spationaute_pays;

-- 13

create view max_spationaute_pays as
select nomp, "nb spationautes"
from nb_spationaute_pays
where "nb spationautes" = (select max("nb spationautes")
                           from nb_spationaute_pays);

/*create view max_spationaute_pays as
select nomp, count
from nb_spationaute_pays
where count = (select max(count)
               from nb_spationaute_pays);*/

select * from max_spationaute_pays;

-- 14

drop table participe;

/* La table participe n'est pas supprimée car elle est utilisée
dans la vue spationaute_pays.
Pour forcer la suppression, on doit écrire
drop table participe cascade;
qui entraîne aussi la suppression des vues qui en dépendent*/
