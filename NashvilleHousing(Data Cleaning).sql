CREATE DATABASE NashvilleHousingdatacleaning

-- Cleaning Data in SQL Queries

SELECT * 
FROM NashvilleDC

-- Standardize Date Format

SELECT Saledate 
FROM NashvilleDC

ALTER TABLE NashvilleDC
ALTER COLUMN Saledate date

--Populate Property Address

SELECT * 
FROM NashvilleDC
order by parcelID

SELECT x.ParcelID, x.Propertyaddress, y.parcelID, y.Propertyaddress, ISNULL(x.propertyaddress,y.propertyaddress)  
FROM NashvilleDC x
JOIN NashvilleDC y
ON x.ParcelID=y.ParcelID
AND x.UniqueID <> y.UniqueID
WHERE x.Propertyaddress IS NULL

UPDATE x
SET propertyaddress = ISNULL(x.propertyaddress,y.propertyaddress)
FROM NashvilleDC x
JOIN NashvilleDC y
ON x.ParcelID=y.ParcelID
AND x.UniqueID <> y.UniqueID
WHERE x.propertyaddress IS NULL

-- Breaking out Addresses into Individual columns (Address, City, State)

SELECT propertyaddress 
FROM NashvilleDC

SELECT 
SUBSTRING (Propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) AS Address,
SUBSTRING (Propertyaddress, CHARINDEX(',',propertyaddress)+1, CHARINDEX(',', propertyaddress)) AS City
FROM NashvilleDC

ALTER TABLE NashvilleDC
ADD PropertySPLITaddress nvarchar(255)

UPDATE NashvilleDC
SET PropertySPLITaddress = SUBSTRING (Propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) 

ALTER TABLE NashvilleDC
ADD PropertySPLITCity nvarchar(255)

UPDATE NashvilleDC
SET PropertySPLITCity = SUBSTRING (Propertyaddress, CHARINDEX(',',propertyaddress)+1, CHARINDEX(',', propertyaddress)) 

SELECT
PARSENAME(REPLACE(Owneraddress, ',', '.'),3),
PARSENAME(REPLACE(Owneraddress, ',', '.'),2),
PARSENAME(REPLACE(Owneraddress, ',', '.'),1)
FROM NashvilleDC

ALTER TABLE NashvilleDC
ADD OwnerSPLITaddress nvarchar(255)

UPDATE NashvilleDC
SET OwnerSPLITaddress = PARSENAME(REPLACE(Owneraddress, ',', '.'),3) 

ALTER TABLE NashvilleDC
ADD OwnerSPLITCity nvarchar(255)

UPDATE NashvilleDC
SET OwnerSPLITCity = PARSENAME(REPLACE(Owneraddress, ',', '.'),2) 

ALTER TABLE NashvilleDC
ADD OwnerSPLITState nvarchar(255)

UPDATE NashvilleDC
SET OwnerSPLITState = PARSENAME(REPLACE(Owneraddress, ',', '.'),1) 

-- Changing Y and N to Yes and No

SELECT DISTINCT (soldasvacant), COUNT(Soldasvacant)
FROM NashvilleDC
GROUP BY soldasvacant
ORDER BY 2

SELECT soldasvacant,
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	 WHEN soldasvacant = 'N' THEN 'No'
	 ELSE soldasvacant
END
FROM NashvilleDC

UPDATE NashvilleDC
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
						WHEN soldasvacant = 'N' THEN 'No'
						ELSE soldasvacant
				   END
FROM NashvilleDC

-- Remove Duplicates

WITH rownumCTE AS 
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, Saleprice, Saledate, legalreference
				   ORDER BY UniqueID) Row_num
FROM NashvilleDC
--ORDER BY parcelID
)
SELECT FROM rownumCTE
WHERE Row_num >1
--ORDER BY Propertyaddress

-- Delete Unused Columns

SELECT * FROM NashvilleDC

ALTER TABLE NashvilleDC
DROP COLUMN propertyaddress, Owneraddress, taxdistrict 