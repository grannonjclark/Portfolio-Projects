-- CLEANING DATA WITH SQL QUERIES --

SELECT *
FROM [Portfolio Project].dbo.nashvillehousing




-- STANDARDIZE DATE FORMATS --

Select SaleDate, CONVERT(Date,SaleDate)
FROM [Portfolio Project].dbo.nashvillehousing

UPDATE nashvillehousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE nashvillehousing
ADD SaleDateConverted Date;

UPDATE nashvillehousing
SET SaleDateConverted = CONVERT(Date, SaleDate)




-- POPULATE PROPERTY ADDRESS DATA --

SELECT *
FROM [Portfolio Project].dbo.nashvillehousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.nashvillehousing AS a
JOIN [Portfolio Project].dbo.nashvillehousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.nashvillehousing AS a
JOIN [Portfolio Project].dbo.nashvillehousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL




-- SEPARATING ADDRESS INTO INDIVIDUAL COLUMNS (ADDREESS, CITY, STATE) --

SELECT PropertyAddress
FROM [Portfolio Project].dbo.nashvillehousing

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM [Portfolio Project].dbo.nashvillehousing

ALTER TABLE nashvillehousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE nashvillehousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM [Portfolio Project].dbo.nashvillehousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Portfolio Project].dbo.nashvillehousing

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE nashvillehousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE nashvillehousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)




-- CHANGE '0' AND '1' TO 'YES' AND 'NO' IN "SOLD AS VACANT" FIELD --

SELECT 
	DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project].dbo.nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = '1' THEN 'Yes'
		WHEN SoldAsVacant = '0' THEN 'No'
		END
FROM [Portfolio Project].dbo.nashvillehousing

ALTER TABLE [Portfolio Project].dbo.nashvillehousing
ADD Sold_As_Vacant NVARCHAR(255);

UPDATE [Portfolio Project].dbo.nashvillehousing
SET Sold_As_Vacant = CASE WHEN SoldAsVacant = '1' THEN 'Yes'
		WHEN SoldAsVacant = '0' THEN 'No'
		END




-- REMOVE DUPLICATES --

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID) row_num
					
FROM [Portfolio Project].dbo.nashvillehousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1




-- DELETE UNUSED COLUMNS --

ALTER TABLE [Portfolio Project].dbo.nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate





