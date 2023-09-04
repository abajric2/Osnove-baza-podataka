--Zadatak 1.
--1.
SELECT DISTINCT p.naziv ResNaziv
FROM fizicko_lice f, pravno_lice p
WHERE f.lokacija_id = p.lokacija_id;
--2.
SELECT DISTINCT To_Char(u.datum_potpisivanja, 'dd.MM.yyyy') "Datum Potpisivanja", pl.naziv ResNaziv
FROM ugovor_za_pravno_lice u, pravno_lice pl
WHERE u.pravno_lice_id = pl.pravno_lice_id AND u.datum_potpisivanja > (SELECT Min(f.datum_kupoprodaje)
                                                                       FROM faktura f, narudzba_proizvoda n, proizvod p
                                                                       WHERE f.faktura_id = n.faktura_id AND n.proizvod_id = p.proizvod_id
                                                                             AND p.broj_mjeseci_garancije IS NOT NULL);
--3.
SELECT p.naziv
FROM proizvod p
WHERE p.kategorija_id = ANY (SELECT p1.kategorija_id
                             FROM proizvod p1
                             WHERE (SELECT Sum(k.kolicina_proizvoda)
                                    FROM kolicina k
                                    WHERE k.proizvod_id = p1.proizvod_id) = (SELECT Max(Sum(k1.kolicina_proizvoda))
                                                                             FROM kolicina k1
                                                                             GROUP BY k1.proizvod_id));
--4.
SELECT p.naziv "Proizvod", pl.naziv "Proizvodjac"
FROM proizvod p, proizvodjac pc, pravno_lice pl
WHERE p.proizvodjac_id =pc.proizvodjac_id AND pc.proizvodjac_id = pl.pravno_lice_id
      AND EXISTS (SELECT p2.proizvod_id
                  FROM proizvod p2
                  WHERE p2.proizvodjac_id = p.proizvodjac_id AND p2.cijena > (SELECT Avg(p3.cijena)
                                                                              FROM proizvod p3));
--5.
SELECT fl.ime || ' ' || fl.prezime "Ime i prezime", Sum(f.iznos) "iznos"
FROM kupac k, uposlenik u, fizicko_lice fl, faktura f
WHERE k.kupac_id = fl.fizicko_lice_id AND u.uposlenik_id = fl.fizicko_lice_id AND
      k.kupac_id = u.uposlenik_id AND f.kupac_id = k.kupac_id
GROUP BY fl.ime, fl.prezime
HAVING Sum(f.iznos) > (SELECT Round(Avg(Sum(f3.iznos)),2)
                       FROM kupac k2, fizicko_lice fl2, faktura f3
                       WHERE f3.kupac_id = fl2.fizicko_lice_id  AND k2.kupac_id = f3.kupac_id
                       GROUP BY fl2.ime, fl2.prezime);
--6.
SELECT pl.naziv "naziv"
FROM kurirska_sluzba ks, pravno_lice pl
WHERE ks.kurirska_sluzba_id = pl.pravno_lice_id AND (SELECT Sum(np.kolicina_jednog_proizvoda)
                                                     FROM narudzba_proizvoda np, isporuka i, faktura f
                                                     WHERE f.faktura_id = np.faktura_id AND f.isporuka_id = i.isporuka_id
                                                           AND ks.kurirska_sluzba_id = i.kurirska_sluzba_id AND
                                                           np.popust_id IS NOT NULL) = (SELECT Max(Sum(np2.kolicina_jednog_proizvoda))
                                                                                        FROM narudzba_proizvoda np2, isporuka i2, faktura f2,
                                                                                             kurirska_sluzba ks2
                                                                                        WHERE f2.faktura_id = np2.faktura_id AND
                                                                                              f2.isporuka_id = i2.isporuka_id AND
                                                                                              ks2.kurirska_sluzba_id = i2.kurirska_sluzba_id AND
                                                                                              np2.popust_id IS NOT NULL
                                                                                        GROUP BY ks2.kurirska_sluzba_id);

--7.
SELECT fl.ime || ' ' ||fl.prezime "Kupac",
       Sum(np.kolicina_jednog_proizvoda*pr.cijena - np.kolicina_jednog_proizvoda*(pr.cijena-(p.postotak/100)*pr.cijena)) "Usteda"
FROM kupac k, fizicko_lice fl, faktura f, narudzba_proizvoda np, popust p, proizvod pr
WHERE k.kupac_id = fl.fizicko_lice_id AND f.kupac_id = k.kupac_id AND f.faktura_id = np.faktura_id
      AND p.popust_id = np.popust_id AND pr.proizvod_id = np.proizvod_id
GROUP BY fl.ime || ' ' || fl.prezime;
--8.
SELECT DISTINCT i.isporuka_id idisporuke, i.kurirska_sluzba_id idkurirske
FROM isporuka i, faktura f, narudzba_proizvoda np, proizvod p
WHERE i.isporuka_id = f.isporuka_id AND f.faktura_id = np.faktura_id AND np.proizvod_id = p.proizvod_id AND
      np.popust_id IS NOT NULL AND p.broj_mjeseci_garancije IS NOT NULL;
--9.
SELECT p.naziv, p.cijena
FROM proizvod p
WHERE p.cijena > (SELECT Round(Avg(Max(p2.cijena)),2)
                  FROM proizvod p2
                  GROUP BY p2.kategorija_id);
--10.
SELECT p.naziv, p.cijena
FROM proizvod p
WHERE p.cijena <ALL (SELECT Avg(p2.cijena)
                     FROM proizvod p2, kategorija k
                     WHERE p2.kategorija_id = k.kategorija_id AND k.nadkategorija_id != p.kategorija_id
                     GROUP BY p2.kategorija_id);

--Zadatak 2.
CREATE TABLE TabelaA (ID           NUMBER,
                      NAZIV        VARCHAR2(50),
                      DATUM        DATE,
                      CIJELIBROJ   NUMBER,
                      REALNIBROJ   NUMBER,
                      CONSTRAINT tabelaa_pk_cons PRIMARY KEY (ID),
                      CONSTRAINT tabelaa_rb_chck_cons CHECK (REALNIBROJ > 5),
                      CONSTRAINT tabelaa_cb_chck_cons CHECK (CIJELIBROJ NOT BETWEEN 5 AND 15));

CREATE TABLE TabelaB (ID           NUMBER,
                      NAZIV        VARCHAR2(50),
                      DATUM        DATE,
                      CIJELIBROJ   NUMBER,
                      REALNIBROJ   NUMBER,
                      FKTABELAA    NUMBER        NOT NULL,
                      CONSTRAINT tabelab_pk_cons  PRIMARY KEY (ID),
                      CONSTRAINT tabelab_fkA_cons FOREIGN KEY (FKTABELAA) REFERENCES TabelaA (ID),
                      CONSTRAINT tabelab_uk_cons  UNIQUE(CIJELIBROJ));

CREATE TABLE TabelaC (ID           NUMBER,
                      NAZIV        VARCHAR2(50)  NOT NULL,
                      DATUM        DATE,
                      CIJELIBROJ   NUMBER        NOT NULL,
                      REALNIBROJ   NUMBER,
                      FKTABELAB    NUMBER,
                      CONSTRAINT tabelac_pk_cons PRIMARY KEY (ID),
                      CONSTRAINT FkCnst FOREIGN KEY (FKTABELAB) REFERENCES TabelaB (ID));

INSERT INTO TabelaA (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ)
             VALUES (1, 'tekst', NULL, NULL, 6.2);
INSERT INTO TabelaA (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ)
             VALUES (2, NULL, NULL, 3, 5.26);
INSERT INTO TabelaA (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ)
             VALUES (3, 'tekst', NULL, 1, NULL);
INSERT INTO TabelaA (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ)
             VALUES (4, NULL, NULL, NULL, NULL);
INSERT INTO TabelaA (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ)
             VALUES (5, 'tekst', NULL, 16, 6.78);

INSERT INTO TabelaB (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAA)
             VALUES (1, NULL, NULL, 1, NULL, 1);
INSERT INTO TabelaB (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAA)
             VALUES (2, NULL, NULL, 3, NULL, 1);
INSERT INTO TabelaB (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAA)
             VALUES (3, NULL, NULL, 6, NULL, 2);
INSERT INTO TabelaB (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAA)
             VALUES (4, NULL, NULL, 11, NULL, 2);
INSERT INTO TabelaB (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAA)
             VALUES (5, NULL, NULL, 22, NULL, 3);

INSERT INTO TabelaC (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAB)
             VALUES (1, 'YES', NULL, 33, NULL, 4);
INSERT INTO TabelaC (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAB)
             VALUES (2, 'NO', NULL, 33, NULL, 2);
INSERT INTO TabelaC (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAB)
             VALUES (3, 'NO', NULL, 55, NULL, 1);

--komande iz zadatka

INSERT INTO TabelaA (id,naziv,datum,cijeliBroj,realniBroj) VALUES (6,'tekst',null,null,6.20);
--ok

INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (6,null,null,1,null,1);
-- Naredba se ne moze izvrsiti jer nad kolonom 'CIJELIBROJ' tabele 'TabelaB' postoji unique ogranicenje,
-- odnosno svaki za svaki slog vrijednosti moraju biti jedinstvene, a pokusavamo unijeti vrijednost '1'
-- koja vec postoji u tabeli


INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (7,null,null,123,null,6);
--ok

INSERT INTO TabelaC (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaB) VALUES (4,'NO',null,55,null,null);
--ok

Update TabelaA set naziv = 'tekst' Where naziv is null and cijeliBroj is not null;
--ok

Drop table tabelaB;
-- ne mozemo obrisati tabelu 'TabelaB' jer tabela 'TabelaC' sadrzi kolonu koja je foreign key na kolonu
-- 'ID' tabele 'TabelaB'

Delete from TabelaA where realniBroj is null;
-- brisanjem kolona koje sadrze NULL vrijednosti u koloni 'REALNIBROJ' obrisali bismo
-- i red sa ID-em jednakim 3, a u tabeli 'TabelaB' imamo kolonu koja je foreign key na kolonu 'ID'
-- tabele 'TabelaA', i ta kolona u tabeli 'TabelaB' izmedju ostalog sadrzi vrijednost 3. Drugim rijecima,
-- obrisali bismo slog na koji referencira foreign key iz tabele 'TabelaB', sto nije dozvoljeno.

Delete from TabelaA where id = 5;
--ok

Update TabelaB set fktabelaA = 4 where fktabelaA = 2;
--ok

Alter Table tabelaA add Constraint cst Check (naziv like 'tekst');
--ok

--Zadatak 3.

DROP TABLE tabelac;
DROP TABLE tabelab;
DROP TABLE tabelaa;

CREATE TABLE TabelaA (ID           NUMBER,
                      NAZIV        VARCHAR2(50),
                      DATUM        DATE,
                      CIJELIBROJ   NUMBER,
                      REALNIBROJ   NUMBER,
                      CONSTRAINT tabelaa_pk_cons PRIMARY KEY (ID),
                      CONSTRAINT tabelaa_rb_chck_cons CHECK (REALNIBROJ > 5),
                      CONSTRAINT tabelaa_cb_chck_cons CHECK (CIJELIBROJ NOT BETWEEN 5 AND 15));

CREATE TABLE TabelaB (ID           NUMBER,
                      NAZIV        VARCHAR2(50),
                      DATUM        DATE,
                      CIJELIBROJ   NUMBER,
                      REALNIBROJ   NUMBER,
                      FKTABELAA    NUMBER        NOT NULL,
                      CONSTRAINT tabelab_pk_cons  PRIMARY KEY (ID),
                      CONSTRAINT tabelab_fkA_cons FOREIGN KEY (FKTABELAA) REFERENCES TabelaA (ID),
                      CONSTRAINT tabelab_uk_cons  UNIQUE(CIJELIBROJ));

CREATE TABLE TabelaC (ID           NUMBER,
                      NAZIV        VARCHAR2(50)  NOT NULL,
                      DATUM        DATE,
                      CIJELIBROJ   NUMBER        NOT NULL,
                      REALNIBROJ   NUMBER,
                      FKTABELAB    NUMBER,
                      CONSTRAINT tabelac_pk_cons PRIMARY KEY (ID),
                      CONSTRAINT FkCnst FOREIGN KEY (FKTABELAB) REFERENCES TabelaB (ID));

INSERT INTO TabelaA (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ)
             VALUES (1, 'tekst', NULL, NULL, 6.2);
INSERT INTO TabelaA (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ)
             VALUES (2, NULL, NULL, 3, 5.26);
INSERT INTO TabelaA (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ)
             VALUES (3, 'tekst', NULL, 1, NULL);
INSERT INTO TabelaA (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ)
             VALUES (4, NULL, NULL, NULL, NULL);
INSERT INTO TabelaA (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ)
             VALUES (5, 'tekst', NULL, 16, 6.78);

INSERT INTO TabelaB (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAA)
             VALUES (1, NULL, NULL, 1, NULL, 1);
INSERT INTO TabelaB (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAA)
             VALUES (2, NULL, NULL, 3, NULL, 1);
INSERT INTO TabelaB (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAA)
             VALUES (3, NULL, NULL, 6, NULL, 2);
INSERT INTO TabelaB (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAA)
             VALUES (4, NULL, NULL, 11, NULL, 2);
INSERT INTO TabelaB (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAA)
             VALUES (5, NULL, NULL, 22, NULL, 3);

INSERT INTO TabelaC (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAB)
             VALUES (1, 'YES', NULL, 33, NULL, 4);
INSERT INTO TabelaC (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAB)
             VALUES (2, 'NO', NULL, 33, NULL, 2);
INSERT INTO TabelaC (ID, NAZIV, DATUM, CIJELIBROJ, REALNIBROJ, FKTABELAB)
             VALUES (3, 'NO', NULL, 55, NULL, 1);


CREATE SEQUENCE seq1
INCREMENT BY 1
START WITH 1
MINVALUE 1;

CREATE SEQUENCE seq2
INCREMENT BY 1
START WITH 1
MINVALUE 1;


CREATE TABLE TabelaABekap AS
SELECT * FROM TabelaA;

ALTER TABLE TabelaABekap ADD CONSTRAINT tabAbkp_pk PRIMARY KEY (ID);
ALTER TABLE TabelaABekap ADD CONSTRAINT tabAbkp_chck_cons_rb CHECK (REALNIBROJ > 5);
ALTER TABLE TabelaABekap ADD CONSTRAINT tabAbkp_chck_cons_cb CHECK (CIJELIBROJ NOT BETWEEN 5 AND 15);

ALTER TABLE TabelaABekap ADD (CIJELIBROJB INTEGER,
                              SEKVENCA    INTEGER);


CREATE OR REPLACE TRIGGER triger1
AFTER INSERT
ON TabelaB
FOR EACH ROW
DECLARE
    id_p NUMBER;
    naziv_p VARCHAR2(50);
    datum_p DATE;
    cijelibroj_p NUMBER;
    realnibroj_p NUMBER;
    brojac INTEGER;
BEGIN
    SELECT Count(*)
    INTO brojac
    FROM tabelaabekap
    WHERE id = :new.fktabelaa;
    IF brojac > 0 THEN
       UPDATE tabelaabekap
       SET cijelibrojb = Nvl(:new.cijelibroj,0) + Nvl(cijelibrojb,0),
           sekvenca = seq1.NEXTVAL
       WHERE id = :new.fktabelaa;
    ELSE
    SELECT *
    INTO id_p, naziv_p, datum_p, cijelibroj_p, realnibroj_p
    FROM TabelaA a
    WHERE a.id = :new.fktabelaa;
    INSERT INTO TabelaABekap VALUES (id_p, naziv_p, datum_p, cijelibroj_p, realnibroj_p, :new.cijelibroj, seq1.NEXTVAL);
    END IF;
END;


CREATE TABLE TabelaBCheck (sekvenca INTEGER PRIMARY KEY);


CREATE OR REPLACE TRIGGER triger2
AFTER DELETE
ON TabelaB
BEGIN
    INSERT INTO TabelaBCheck (sekvenca) VALUES(seq2.NEXTVAL - 1);
END;


CREATE OR REPLACE PROCEDURE procedura1
(cb IN NUMBER) IS
    suma INTEGER;
    brojac INTEGER;
    id_p NUMBER;
BEGIN
    SELECT Sum(cijelibroj)
    INTO suma
    FROM tabelaa;
    SELECT Max(id) + 1
    INTO id_p
    FROM tabelac;
    brojac := 0;
    WHILE brojac < suma
      LOOP
        INSERT INTO tabelac VALUES (id_p, 'YES', NULL, cb, NULL, NULL);
        id_p := id_p + 1;
        brojac := brojac + 1;
      END LOOP;
END;

--komande iz zadatka

INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (6,null,null,2,null,1);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (7,null,null,4,null,2);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (8,null,null,8,null,1);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (9,null,null,5,null,3);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (10,null,null,7,null,3);
INSERT INTO TabelaB (id,naziv,datum,cijeliBroj,realniBroj,FkTabelaA) VALUES (11,null,null,9,null,5);
Delete From TabelaB where id not in (select FkTabelaB from TabelaC);
Alter TABLE tabelaC drop constraint FkCnst;
Delete from TabelaB where 1=1;
call procedura1(1);