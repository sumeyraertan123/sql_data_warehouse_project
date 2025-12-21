-- 1. cst_id'nin uniqıness'ini kontrol edicem ilk önce
SELECT
	cst_id, COUNT (*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT (*) > 1 OR cst_id IS NULL

-- 2. cst_id için birden fazla aynı var ve farklı tarihlerde en günzel olanını alıcaz
--latest record per group
SELECT *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER ( -- row numberda bu sıralmayı 123 şeklinde sıralar
            PARTITION BY cst_id -- aynı customer id'ye sahip olanları gruba ayır
            ORDER BY cst_create_date DESC -- ve azalan sırada sırala en günzel en üstte yani
        ) AS flag_last --yeni bir kolon olarak bu sıralama numarasını görürüm
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t -- altsorguyu alabilmesi için from'un içindeki altsorguyu t olarak adlandırdık
WHERE flag_last = 1; --flag_last oluşturdum 1 olanlar en güncelleridir yani tekrarlanan id_lerden kurtuldum



-- 3. boşluk kontorlü
SELECT cst_lastname FROM bronze.crm_cust_info
WHERE TRIM(cst_lastname) != cst_lastname

-- 4. low cardinality quality kontrol
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info
