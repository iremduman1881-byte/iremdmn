CREATE DATABASE OnlineAlisveris;
USE OnlineAlisveris;

CREATE TABLE Musteri (
id INT IDENTITY PRIMARY KEY,
[ad] VARCHAR(50) NOT NULL,
soyad VARCHAR(50) NOT NULL,
email VARCHAR(80) NOT NULL,
kayit_tarihi DATE
);

CREATE TABLE Kategori(
id INT IDENTITY PRIMARY KEY,
ad VARCHAR(80) NOT NULL
);

CREATE TABLE Satici (
id INT IDENTITY PRIMARY KEY, 
ad VARCHAR(100) NOT NULL, 
adres VARCHAR(250)
);

CREATE TABLE Urun (
id INT IDENTITY PRIMARY KEY,
ad VARCHAR(100) NOT NULL,
fiyat DECIMAL(10,2) NOT NULL,
stok INT NOT NULL,
kategori_id INT,
satici_id INT,
FOREIGN KEY (kategori_id) REFERENCES Kategori(id),
FOREIGN KEY (satici_id) REFERENCES Satici(id)
);
CREATE TABLE Siparis (
id INT IDENTITY PRIMARY KEY,
musteri_id INT,
tarih DATE,
toplam_tutar DECIMAL(10,2),
odeme_turu VARCHAR(40) CHECK(odeme_turu IN ('Kredi Kartý', 'Havale', 'Kapýda Ödeme')),
FOREIGN KEY (musteri_id) REFERENCES Musteri(id)
);

CREATE TABLE Siparis_Detay (
id INT IDENTITY PRIMARY KEY,
siparis_id INT,
urun_id INT,
adet INT,
fiyat DECIMAL(10,2),
FOREIGN KEY (siparis_id) REFERENCES Siparis(id),
FOREIGN KEY (urun_id) REFERENCES Urun(id)
);

INSERT INTO Musteri (ad,soyad,email,kayit_tarihi) VALUES
('Irem', 'Duman', 'iremduman1881@gmail.com', '2022-07-01'),
('Ilayda', 'Şeker', 'ilaydaseker1881@gmail.com', '2022-11-26'),
('Atlas', 'Bido', 'atlasbido1881@gmail.com', '2022-07-10');

INSERT INTO Kategori(ad) VALUES
('Giyim'),
('Kitap'),
('Bebek'),
('Elektronik');

INSERT INTO Satici (ad,adres) VALUES
('ActModa', 'Mersin'),
('ÝFbaby', 'Ankara'),
('KitapMarket', 'Ýstanbul'),
('TECH', 'Ýzmir');

INSERT INTO Urun(ad,fiyat,stok,kategori_id,satici_id) VALUES
('Elbise', 150, 15, 1, 1),
('Laptop', 25000, 250, 4, 4),
('Biberon', 120, 80, 3, 2),
('Roman', 80, 100, 2, 3);

INSERT INTO Siparis (musteri_id, tarih, toplam_tutar, odeme_turu) VALUES
(1, '09-08-2022',150, 'Kredi Kartý'),
(2, '09-11-2022', 25000, 'Havale'),
(3, '11-12-2022', 120, 'Kapýda Ödeme');

INSERT INTO Siparis_Detay( siparis_id, urun_id, adet, fiyat) VALUES
(1, 1, 1, 1550), -- Irem elbise aldý
(2, 2, 1, 25000), -- Ilayda laptop aldý
(3, 3, 1, 120); -- Atlas biberon aldý

--STOK güncelleme
UPDATE Urun SET stok = stok -1 WHERE id = 1; -- Elbise stoktan düþ
-- Fiyat güncelleme
UPDATE Urun set fiyat = 200 WHERE ad = 'Elbise';

-- En çok sipariþ veren müþteriler
SELECT m.ad, m.soyad, COUNT(s.id) AS siparis_sayisi
FROM Musteri m
LEFT JOIN Siparis s ON m.id = s.musteri_id
GROUP BY m.ad, m.soyad
ORDER BY siparis_sayisi DESC;

-- En yüksek cirosu olan satýcýlar
SELECT TOP 4
    s.ad AS SaticiAdi,
SUM(sd.adet * sd.fiyat) AS ToplamCiro
FROM Satici s
INNER JOIN Urun u ON s.id = u.satici_id
INNER JOIN Siparis_Detay sd ON u.id = sd.urun_id
GROUP BY s.ad
ORDER BY ToplamCiro DESC;


-- Kategori bazlý toplam satýþlar
SELECT 
    k.ad AS KategoriAdi,
    SUM(sd.adet * sd.fiyat) AS ToplamSatis
FROM Kategori k
INNER JOIN Urun u ON k.id = u.kategori_id
INNER JOIN Siparis_Detay sd ON u.id = sd.urun_id
GROUP BY k.ad
ORDER BY ToplamSatis DESC;

-- Aylara göre sipariþ sayýsý
SELECT 
    YEAR(tarih) AS Yil,
    MONTH(tarih) AS Ay,
    COUNT(*) AS SiparisSayisi
FROM Siparis
GROUP BY YEAR(tarih), MONTH(tarih)
ORDER BY Yil, Ay;

-- Müþteri,ürün, satýcý bilgisi
SELECT 
    m.ad AS MusteriAd,
    m.soyad AS MusteriSoyad,
    u.ad AS UrunAdi,
    s.ad AS SaticiAdi,
    sd.adet,
    sd.fiyat,
    (sd.adet * sd.fiyat) AS ToplamTutar
FROM Siparis_Detay sd
INNER JOIN Siparis sp ON sd.siparis_id = sp.id
INNER JOIN Musteri m ON sp.musteri_id = m.id
INNER JOIN Urun u ON sd.urun_id = u.id
INNER JOIN Satici s ON u.satici_id = s.id
ORDER BY sp.id;


-- Hiç satýlmamýþ ürünler
SELECT u.ad AS UrunAdi
FROM Urun u
LEFT JOIN Siparis_Detay sd ON u.id = sd.urun_id
WHERE sd.id IS NULL;


--Hiç Sipariþ Vermemiþ müþteriler
SELECT m.ad, m.soyad
FROM Musteri m
LEFT JOIN Siparis s ON m.id = s.musteri_id
WHERE s.id IS NULL;



