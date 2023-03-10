-- Data Cleaning using SQL
--1.Sales Date column is DateTime --> Date: taking off the Hours
SELECT SaleDate, CONVERT(Date, SaleDate) AS SaleConverted FROM PortfolioProject2..HousingData
--
ALTER TABLE HousingData
ADD SalesConv Date
--
UPDATE HousingData
SET HousingData.SalesConv = CONVERT(Date, HousingData.SaleDate)
--
SELECT SaleDate, SalesConv FROM PortfolioProject2..HousingData
--
SELECT * FROM PortfolioProject2..HousingData 
ORDER BY ParcelID
--Compare rows using self join/ we noticed that if two rows have the same parceID and one of them has the adress missing
-- he has the same Adresse as the first one 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress FROM PortfolioProject2..HousingData a
JOIN PortfolioProject2..HousingData b
ON a.ParcelID = b.ParcelID
WHERE a.[UniqueID ] <> b.[UniqueID ] AND a.PropertyAddress IS NULL
--filling the missing adresses by using the function ISNULL
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress) AS Adress2
FROM PortfolioProject2..HousingData a
JOIN PortfolioProject2..HousingData b
ON a.ParcelID = b.ParcelID
WHERE a.[UniqueID ] <> b.[UniqueID ] AND a.PropertyAddress IS NULL
--updating the data table // filling missing values
UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject2..HousingData a
JOIN PortfolioProject2..HousingData b
ON a.ParcelID = b.ParcelID
WHERE a.PropertyAddress IS NULL
-- notice that 2 rows remain without adress so let"s remove them
SELECT ParcelID,PropertyAddress From HousingData WHERE PropertyAddress is null
DELETE FROM HousingData WHERE PropertyAddress IS NULL

-- separate the adress from property adress column using CharIndex function: it returns a number the delimetre here is a comHousingData.PropertyAddress FROM HousingData
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as adress1 ,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as adress2
FROM HousingData

--updating the table
ALTER TABLE HousingData
ADD PropertySplitAddress nvarchar(255)
UPDATE HousingData
SET HousingData.PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
ALTER TABLE HousingData
ADD PropertySplitCity nvarchar(255)
UPDATE HousingData
SET HousingData.PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--checking the results
SELECT HousingData.PropertyAddress,HousingData.PropertySplitAddress,HousingData.PropertySplitCity FROM HousingData

--lets do the same thing for owner address using parsename it works with .
SELECT 
PARSENAME(REPLACE (OwnerAddress,',','.'),3),
PARSENAME(REPLACE (OwnerAddress,',','.'),2),
PARSENAME(REPLACE (OwnerAddress,',','.'),1) 
FROM HousingData

--Updating the table
ALTER TABLE HousingData
ADD OwnerSplitAddress nvarchar(255)
UPDATE HousingData
SET HousingData.OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress,',','.'),3)
ALTER TABLE HousingData
ADD OwnerSplitCity nvarchar(255)
UPDATE HousingData
SET HousingData.OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress,',','.'),2)
ALTER TABLE HousingData
ADD OwnerSplitState nvarchar(255)
UPDATE HousingData
SET HousingData.OwnerSplitState = PARSENAME(REPLACE (OwnerAddress,',','.'),1)

--check the results
SELECT HousingData.OwnerAddress, HousingData.OwnerSplitAddress, HousingData.OwnerSplitCity, HousingData.OwnerSplitState FROM HousingData

--checking the solde as vacant column values
SELECT DISTINCT (HousingData.SoldAsVacant), COUNT(HousingData.SoldAsVacant)
FROM HousingData 
GROUP BY SoldAsVacant
Order By 2

-- changing y to yes nd n to no
SELECT
CASE 
WHEN HousingData.SoldAsVacant = 'N' THEN 'No'
WHEN HousingData.SoldAsVacant = 'Y' THEN 'Yes'
ELSE HousingData.SoldAsVacant
END
FROM HousingData
-- update the results
UPDATE HousingData
SET SoldAsVacant =
CASE 
WHEN HousingData.SoldAsVacant = 'N' THEN 'No'
WHEN HousingData.SoldAsVacant = 'Y' THEN 'Yes'
ELSE HousingData.SoldAsVacant
END

--removing duplicates
WITH RowCTE AS (
SELECT *,ROW_NUMBER() OVER (PARTITION BY
ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) rownum
FROM HousingData)
SELECT *FROM RowCTE WHERE rownum >1 
--deleting the duplicates
DELETE FROM RowCTE WHERE rownum >1

--Dealiting some columns
ALTER TABLE PortfolioProject2..HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
