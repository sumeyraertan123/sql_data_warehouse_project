--duplicates or nulls in the primary key (product id)
SELECT
prd_id,
COUNT (*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT (*) > 1 or prd_id IS NULL

--integration grafiğine bakarsan eğer sales tablosundaki prd_key ile 
--bağlantıları var ama 5. karakterden sonrası yani ilk 5 karakter category_id aslında
--o zaman prd_key'i eşlemem lazım ilk 5 karakteri çıkartıp yeni sütun yapıcaz 
-- substring kullanıcaz işlem yapacağın sütun, başlama noktası, kaç karakter sub etmek istediğin
SUBSTRING(prd_key, 1, 5) AS cat_id

--artık erp_px_cat tablosu ile bağdaştırabileceğin cat_id var
--zaten integration grafiğinde görebilirsin
SELECT DISTINCT id from bronze.erp_px_cat_g1v2

-- tam eşlenmesini istiyoruz erp tablosunda  _ var, prd tablosunda - : bunu düzelticez 
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id

-- prd tablosundaki her şey erp'dekiyle eşleniyor mu farklı olanlar ne diye sorgulayacak olursak
-- FROM'dan sonra 
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN (SELECT DISTINCT id from bronze.erp_px_cat_g1v2) --yapabiliriz

-- şimdi sales tablosundaki prd_key ile kontrol edicez
SELECT sls_prd_key FROM bronze.crm_sales_details

-- prd ile sales'in prd_key farkına bakalım
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN (SELECT DISTINCT sls_prd_key from bronze.crm_sales_details)
-- çok fazla fark çıktı, başka şeyler deneyelim
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN (SELECT DISTINCT sls_prd_key from bronze.crm_sales_details WHERE sls_prd_key LIKE 'FK%')
--üstteki gibi kontrol edince bir sıkıntı çıkmadı not ın yerine in diye de kontrol ettik şimdilik okey olarak bakıyoruz

--prd_nm için boşluk kontorlü yapalım (sıkıntı yok)
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE TRIM(prd_nm) != prd_nm

-- prd_cost için null ve negatif sayı kontrolü yapalım (NULL'U 0 İLE DEĞİŞTİRDİM)
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--low cardinality control (prd_line için) (full name vericez)
SELECT DISTINCT prd_line FROM bronze.crm_prd_info

-- invalid date için kontrol (prd_start/end dt için)
SELECT *
FROM bronze.crm_prd_info
WHERE  prd_end_dt < prd_start
-- burada bir çok hata var sanki yer değiştirmiş gibi düzenlememiz lazım

-- iki şartımız var
-- başlangıç bitişten küçük olmalı ama
-- 1.'nin bitişi 2.'nin başlangıcından küçük olmalı yoksa overlapping olur
-- 2.nin başından 1 çıkart ve 1.'nin sonuna koy

SELECT
	prd_id,
	prd_key,
	prd_nm,
	prd_start,
	prd_end_dt,
	LEAD(prd_start) OVER (PARTITION BY prd_key ORDER BY prd_start)-1 AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')

--“Aynı prd_key grubunda, prd_start'a göre sıralanmış listede → bir sonraki satırın prd_start değerini getir.”
LEAD(prd_start) OVER (
    PARTITION BY prd_key
    ORDER BY prd_start
)

-- yaptığın değişikliklerden sonra DDL scriptini güncellemyi unutma


SELECT *  FROM bronze.crm_prd_info
