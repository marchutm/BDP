-- 1. Utwórz nową bazę danych nazywając ją firma.
CREATE DATABASE firma;

-- 2. Dodaj schemat o nazwie ksiegowosc.
CREATE SCHEMA ksiegowosc;

-- 3. Dodaj tabele
CREATE TABLE ksiegowosc.pracownicy(
	id_pracownika SERIAL PRIMARY KEY,
	imie VARCHAR(255) NOT NULL,
	nazwisko VARCHAR(255) NOT NULL,
	adres TEXT,
	telefon VARCHAR(15)
);
COMMENT ON TABLE ksiegowosc.pracownicy IS 'Tabela przechowująca dane o pracownikach';
COMMENT ON COLUMN ksiegowosc.pracownicy.id_pracownika IS 'Unikalny identyfikator pracownika';
COMMENT ON COLUMN ksiegowosc.pracownicy.imie IS 'Imię pracownika';
COMMENT ON COLUMN ksiegowosc.pracownicy.nazwisko IS 'Nazwisko pracownika';
COMMENT ON COLUMN ksiegowosc.pracownicy.adres IS 'Adres zamieszkania pracownika';
COMMENT ON COLUMN ksiegowosc.pracownicy.telefon IS 'Numer telefonu pracownika';

CREATE TABLE ksiegowosc.godziny(
	id_godziny SERIAL PRIMARY KEY,
	data DATE NOT NULL,
	liczba_godzin INTEGER NOT NULL,
	id_pracownika INTEGER,
	FOREIGN KEY (id_pracownika) REFERENCES ksiegowosc.pracownicy(id_pracownika) 
);
COMMENT ON TABLE ksiegowosc.godziny IS 'Tabela przechowująca informacje o godzinach pracy pracowników';
COMMENT ON COLUMN ksiegowosc.godziny.id_godziny IS 'Unikalny identyfikator zapisu godzin pracy';
COMMENT ON COLUMN ksiegowosc.godziny.data IS 'Data przepracowanych godzin';
COMMENT ON COLUMN ksiegowosc.godziny.liczba_godzin IS 'Liczba przepracowanych godzin';
COMMENT ON COLUMN ksiegowosc.godziny.id_pracownika IS 'Klucz obcy odnoszący się do pracownika';

CREATE TABLE ksiegowosc.pensja(
	id_pensji SERIAL PRIMARY KEY,
	stanowisko VARCHAR(255) NOT NULL,
	kwota DECIMAL(10,2) NOT NULL
);
COMMENT ON TABLE ksiegowosc.pensja IS 'Tabela przechowująca informacje o pensjach pracowników';
COMMENT ON COLUMN ksiegowosc.pensja.id_pensji IS 'Unikalny identyfikator pensji';
COMMENT ON COLUMN ksiegowosc.pensja.stanowisko IS 'Stanowisko pracownika';
COMMENT ON COLUMN ksiegowosc.pensja.kwota IS 'Kwota wynagrodzenia (pensji)';

CREATE TABLE ksiegowosc.premia(
	id_premii SERIAL PRIMARY KEY,
	rodzaj VARCHAR(100) NOT NULL,
	kwota DECIMAL(8, 2) NOT NULL
);
COMMENT ON TABLE ksiegowosc.premia IS 'Tabela przechowująca informacje o premiach pracowników';
COMMENT ON COLUMN ksiegowosc.premia.id_premii IS 'Unikalny identyfikator premii';
COMMENT ON COLUMN ksiegowosc.premia.rodzaj IS 'Rodzaj przyznanej premii';
COMMENT ON COLUMN ksiegowosc.premia.kwota IS 'Kwota premii';

CREATE TABLE ksiegowosc.wynagrodzenie(
	id_wynagrodzenia SERIAL PRIMARY KEY,
	data DATE NOT NULL,
	id_pracownika INTEGER,
	id_godziny INTEGER, 
	id_pensji INTEGER,
	id_premii INTEGER,
	FOREIGN KEY (id_pracownika) REFERENCES ksiegowosc.pracownicy(id_pracownika),
	FOREIGN KEY (id_godziny) REFERENCES ksiegowosc.godziny(id_godziny),
	FOREIGN KEY (id_pensji) REFERENCES ksiegowosc.pensja(id_pensji),
	FOREIGN KEY (id_premii) REFERENCES ksiegowosc.premia(id_premii)
);
COMMENT ON TABLE ksiegowosc.wynagrodzenie IS 'Tabela przechowująca informacje o wynagrodzeniach pracowników, w tym pensje, premie i godziny pracy';
COMMENT ON COLUMN ksiegowosc.wynagrodzenie.id_wynagrodzenia IS 'Unikalny identyfikator wynagrodzenia';
COMMENT ON COLUMN ksiegowosc.wynagrodzenie.data IS 'Data wypłaty wynagrodzenia';
COMMENT ON COLUMN ksiegowosc.wynagrodzenie.id_pracownika IS 'Klucz obcy odnoszący się do pracownika';
COMMENT ON COLUMN ksiegowosc.wynagrodzenie.id_godziny IS 'Klucz obcy odnoszący się do liczby przepracowanych godzin';
COMMENT ON COLUMN ksiegowosc.wynagrodzenie.id_pensji IS 'Klucz obcy odnoszący się do pensji';
COMMENT ON COLUMN ksiegowosc.wynagrodzenie.id_premii IS 'Klucz obcy odnoszący się do premii';

-- 4. Wypełnij każdą tabelę 10 rekordami.
INSERT INTO ksiegowosc.pracownicy (imie, nazwisko, adres, telefon) VALUES
('Jan', 'Kowalski', 'Warszawa, ul. Lipowa 1', '123456789'),
('Anna', 'Nowak', 'Kraków, ul. Dębowa 2', '987654321'),
('Piotr', 'Wiśniewski', 'Łódź, ul. Topolowa 3', '543219876'),
('Maria', 'Wójcik', 'Gdańsk, ul. Brzozowa 4', '678912345'),
('Krzysztof', 'Kaczmarek', 'Poznań, ul. Świerkowa 5', '112233445'),
('Ewa', 'Zielińska', 'Wrocław, ul. Klonowa 6', '554433221'),
('Tomasz', 'Szymański', 'Katowice, ul. Cisowa 7', '667788990'),
('Magdalena', 'Lewandowska', 'Szczecin, ul. Wierzbowa 8', '998877665'),
('Paweł', 'Dąbrowski', 'Bydgoszcz, ul. Modrzewiowa 9', '111222333'),
('Agnieszka', 'Pawlak', 'Lublin, ul. Jodłowa 10', '444555666');

INSERT INTO ksiegowosc.godziny (data, liczba_godzin, id_pracownika) VALUES
('2024-10-01', 8, 1),
('2024-10-01', 7, 2),
('2024-10-01', 6, 3),
('2024-10-01', 8, 4),
('2024-10-01', 5, 5),
('2024-10-01', 8, 6),
('2024-10-01', 7, 7),
('2024-10-01', 6, 8),
('2024-10-01', 8, 9),
('2024-10-01', 5, 10);

INSERT INTO ksiegowosc.pensja (stanowisko, kwota) VALUES
('Programista', 6000.00),
('Analityk', 5000.00),
('Administrator', 5500.00),
('Projektant', 6200.00),
('Tester', 4000.00),
('Kierownik', 7000.00),
('HR', 4500.00),
('Sekretarka', 3200.00),
('Marketing', 4800.00),
('Grafik', 5300.00);

INSERT INTO ksiegowosc.premia (rodzaj, kwota) VALUES
('Świąteczna', 1000.00),
('Roczna', 1200.00),
('Miesięczna', 500.00),
('Za projekt', 800.00),
('Okazjonalna', 600.00),
('Motywacyjna', 400.00),
('Specjalna', 700.00),
('Uznaniowa', 900.00),
('Przedsprzedażowa', 1500.00),
('Sezonowa', 1100.00);

INSERT INTO ksiegowosc.wynagrodzenie (data, id_pracownika, id_godziny, id_pensji, id_premii) VALUES
('2024-10-31', 1, 1, 1, 1),
('2024-10-31', 2, 2, 2, 2),
('2024-10-31', 3, 3, 3, 3),
('2024-10-31', 4, 4, 4, 4),
('2024-10-31', 5, 5, 5, 5),
('2024-10-31', 6, 6, 6, 6),
('2024-10-31', 7, 7, 7, 7),
('2024-10-31', 8, 8, 8, 8),
('2024-10-31', 9, 9, 9, 9),
('2024-10-31', 10, 10, 10, 10);

-- 5

-- a) Wyświetl tylko id pracownika oraz jego nazwisko.
SELECT id_pracownika, nazwisko FROM ksiegowosc.pracownicy;

-- b) Wyświetl id pracowników, których płaca jest większa niż 1000.
SELECT p.id_pracownika
FROM ksiegowosc.wynagrodzenie AS w
JOIN ksiegowosc.pracownicy AS p ON w.id_pracownika=p.id_pracownika
JOIN ksiegowosc.pensja AS pe ON w.id_pensji=pe.id_pensji
JOIN ksiegowosc.premia AS pr ON w.id_premii=pr.id_premii
WHERE pe.kwota + pr.kwota > 1000;

-- c) Wyświetl id pracowników nieposiadających premii, których płaca jest większa niż 2000.
SELECT p.id_pracownika
FROM ksiegowosc.wynagrodzenie AS w
JOIN ksiegowosc.pracownicy AS p ON w.id_pracownika=p.id_pracownika
JOIN ksiegowosc.pensja AS pe ON w.id_pensji=pe.id_pensji
JOIN ksiegowosc.premia AS pr ON w.id_premii=pr.id_premii
WHERE pr.kwota = 0
  AND pe.kwota > 2000;

-- d) Wyświetl pracowników, których pierwsza litera imienia zaczyna się na literę ‘J’.
SELECT *
FROM ksiegowosc.pracownicy
WHERE LEFT(imie, 1)='J';

-- e) Wyświetl pracowników, których nazwisko zawiera literę ‘n’ oraz imię kończy się na literę ‘a’.
SELECT *
FROM ksiegowosc.pracownicy
WHERE nazwisko LIKE '%n%'
  AND RIGHT(imie, 1)='a';

-- f) Wyświetl imię i nazwisko pracowników oraz liczbę ich nadgodzin, przyjmując, iż standardowy czas pracy to 160 h miesięcznie.
SELECT p.imie,
       p.nazwisko,
       SUM(g.liczba_godzin) - 160 AS liczba_nadgodzin
FROM ksiegowosc.pracownicy AS p
JOIN ksiegowosc.godziny AS g ON p.id_pracownika=g.id_pracownika
GROUP BY g.id_pracownika,
         p.imie,
         p.nazwisko
HAVING SUM(g.liczba_godzin) > 160;

-- g) Wyświetl imię i nazwisko pracowników, których pensja zawiera się w przedziale 1500 – 3000 PLN.
SELECT p.imie,
       p.nazwisko,
       pe.kwota
FROM ksiegowosc.wynagrodzenie AS w
JOIN ksiegowosc.pracownicy AS p ON w.id_pracownika=p.id_pracownika
JOIN ksiegowosc.pensja AS pe ON w.id_pensji=pe.id_pensji
WHERE pe.kwota BETWEEN 1500 AND 3000;

-- h) Wyświetl imię i nazwisko pracowników, którzy pracowali w nadgodzinach i nie otrzymali premii.
SELECT p.imie,
       p.nazwisko
FROM ksiegowosc.pracownicy AS p
JOIN ksiegowosc.godziny AS g ON p.id_pracownika=g.id_pracownika
JOIN ksiegowosc.wynagrodzenie AS w ON p.id_pracownika=w.id_pracownika
JOIN ksiegowosc.premia AS pr ON w.id_premii=pr.id_premii
GROUP BY g.id_pracownika,
         p.imie,
         p.nazwisko,
         pr.kwota
HAVING SUM(g.liczba_godzin) > 160
AND pr.kwota=0;

-- i) Uszereguj pracowników według pensji.
SELECT p.imie,
       p.nazwisko,
       pe.kwota
FROM ksiegowosc.wynagrodzenie AS w
JOIN ksiegowosc.pracownicy AS p ON w.id_pracownika=p.id_pracownika
JOIN ksiegowosc.pensja AS pe ON w.id_pensji=pe.id_pensji
ORDER BY pe.kwota DESC;

-- j) Uszereguj pracowników według pensji i premii malejąco.
SELECT p.imie,
       p.nazwisko,
       pe.kwota + pr.kwota
FROM ksiegowosc.wynagrodzenie AS w
JOIN ksiegowosc.pracownicy AS p ON w.id_pracownika=p.id_pracownika
JOIN ksiegowosc.pensja AS pe ON w.id_pensji=pe.id_pensji
JOIN ksiegowosc.premia AS pr ON w.id_premii=pr.id_premii
ORDER BY pe.kwota + pr.kwota DESC;

-- k) Zlicz i pogrupuj pracowników według pola ‘stanowisko’.

SELECT stanowisko,
       COUNT(*)
FROM ksiegowosc.pensja
GROUP BY stanowisko;

-- l) Policz średnią, minimalną i maksymalną płacę dla stanowiska ‘kierownik’ (jeżeli takiego nie masz, to przyjmij dowolne inne).
SELECT stanowisko,
       AVG(kwota),
       MAX(kwota),
       MIN(kwota)
FROM ksiegowosc.pensja
GROUP BY stanowisko
HAVING stanowisko='Kierownik';

-- m) Policz sumę wszystkich wynagrodzeń.
SELECT SUM(pe.kwota+pr.kwota) AS suma_wynagrodzen
FROM ksiegowosc.wynagrodzenie AS w
JOIN ksiegowosc.premia AS pr ON w.id_premii=pr.id_premii
JOIN ksiegowosc.pensja AS pe ON w.id_pensji=pe.id_pensji;

-- n) Policz sumę wynagrodzeń w ramach danego stanowiska.
SELECT pe.stanowisko,
       SUM(pe.kwota+pr.kwota) AS suma_wynagrodzen
FROM ksiegowosc.wynagrodzenie AS w
JOIN ksiegowosc.premia AS pr ON w.id_premii=pr.id_premii
JOIN ksiegowosc.pensja AS pe ON w.id_pensji=pe.id_pensji
GROUP BY pe.stanowisko;

-- o) Wyznacz liczbę premii przyznanych dla pracowników danego stanowiska.
SELECT pe.stanowisko,
       COUNT(pr.id_premii) AS liczba_premii
FROM ksiegowosc.wynagrodzenie AS w
JOIN ksiegowosc.premia AS pr ON w.id_premii=pr.id_premii
JOIN ksiegowosc.pensja AS pe ON w.id_pensji=pe.id_pensji
GROUP BY pe.stanowisko;

-- p) Usuń wszystkich pracowników mających pensję mniejszą niż 1200 zł.
DELETE
FROM ksiegowosc.pracownicy
WHERE id_pracownika IN
    (SELECT p.id_pracownika
     FROM ksiegowosc.wynagrodzenie AS w
     JOIN ksiegowosc.pensja AS pe ON w.id_pensji = pe.id_pensji
     JOIN ksiegowosc.pracownicy AS p ON w.id_pracownika = p.id_pracownika
     WHERE pe.kwota < 1200);