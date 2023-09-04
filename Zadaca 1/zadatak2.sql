--1.
SELECT Nvl(d.naziv, 'Nema drzave') AS Drzava, Nvl(g.naziv, 'Nema grada') AS Grad, k.naziv AS Kontinent
FROM kontinent k, drzava d, grad g
WHERE d.drzava_id=g.drzava_id(+) AND k.kontinent_id=d.kontinent_id(+);
--2.
SELECT DISTINCT p.naziv
FROM pravno_lice p, ugovor_za_pravno_lice u 
WHERE p.pravno_lice_id=u.pravno_lice_id AND u.datum_potpisivanja BETWEEN To_Date('2014', 'yyyy') AND To_Date('2016','yyyy');
--3.
SELECT k.kolicina_proizvoda AS Kolicina_proizvoda, p.naziv AS Proizvod, d.naziv AS Drzava
FROM proizvod p, kolicina k, drzava d, grad g, lokacija l, skladiste s
WHERE p.proizvod_id=k.proizvod_id AND d.drzava_id=g.drzava_id and l.grad_id=g.grad_id and s.lokacija_id=l.lokacija_id AND k.skladiste_id=s.skladiste_id 
      AND k.kolicina_proizvoda>50 AND Lower(d.naziv) NOT LIKE '%s%s%';
--4.
SELECT DISTINCT pr.naziv, pr.broj_mjeseci_garancije
FROM proizvod pr, popust p, narudzba_proizvoda n
WHERE pr.proizvod_id=n.proizvod_id AND p.popust_id=n.popust_id AND p.popust_id IS NOT NULL AND
      Mod(pr.broj_mjeseci_garancije,3)=0;
--5.
SELECT f.ime || ' ' || f.prezime AS "ime i prezime", o.naziv AS "Naziv odjela", 18892 AS "Indeks"
FROM fizicko_lice f, uposlenik u, kupac k, odjel o
WHERE f.fizicko_lice_id=k.kupac_id AND u.uposlenik_id=f.fizicko_lice_id AND 
      u.odjel_id=o.odjel_id AND o.sef_id<>f.fizicko_lice_id;
--6.
SELECT DISTINCT n.narudzba_id AS Narudzba_id, p.cijena AS Cijena, 
       Decode(n.popust_id, NULL, 0, po.postotak) AS Postotak, 
       Decode(n.popust_id, NULL, 0, po.postotak/100) AS PostotakRealni
FROM narudzba_proizvoda n, proizvod p, popust po
WHERE n.proizvod_id=p.proizvod_id AND (n.popust_id=po.popust_id OR n.popust_id IS NULL) AND po.postotak*p.cijena/100<200;
--7.
SELECT Decode(k.kategorija_id, 1, 'Komp Oprema', NULL, 'Nema Kategorije', k.naziv) AS "Kategorija", 
       Decode(k2.kategorija_id, 1, 'Komp Oprema', NULL, 'Nema Kategorije', k2.naziv) AS "Nadkategorija"
FROM kategorija k, kategorija k2
WHERE k.nadkategorija_id=k2.kategorija_id(+);
--8.
SELECT Floor(months_between(To_Date('10-10-2020', 'dd-mm-yyyy'), datum_potpisivanja)/12) AS Godina, 
       Floor(Mod(months_between(To_Date('10-10-2020', 'dd-mm-yyyy'), datum_potpisivanja),12)) AS Mjeseci,
       Floor(To_Date('10-10-2020','dd-mm-yyyy')-Add_Months(datum_potpisivanja, Floor(Months_Between(To_Date('10-10-2020', 'dd-mm-yyyy'), datum_potpisivanja)))) AS Dana                    
FROM ugovor_za_pravno_lice
WHERE months_between(To_Date('10-10-2020', 'dd-mm-yyyy'), datum_potpisivanja)/12>To_Number(SubStr(ugovor_id,0,2));
--9.
SELECT f.ime AS ime, f.prezime AS prezime, 
       Decode(o.naziv, 'Managment', 'MANAGER', 'Human Resources', 'HUMAN', 'OTHER') AS Odjel, o.odjel_id AS odjel_id
FROM fizicko_lice f, uposlenik u, odjel o
WHERE u.uposlenik_id=f.fizicko_lice_id AND u.odjel_id=o.odjel_id
ORDER BY f.ime ASC, f.prezime DESC; 
--10.
SELECT k.naziv, p1.naziv AS Najjeftiniji, p2.naziv AS Najskuplji, p1.cijena+p2.cijena AS ZCijena
FROM kategorija k, proizvod p1, proizvod p2
WHERE (p1.cijena, p2.cijena) = (SELECT Min(cijena), Max(cijena)
                                FROM proizvod
                                WHERE kategorija_id=k.kategorija_id)
ORDER BY ZCijena;
