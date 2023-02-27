--Cleaning data in SQL Queries

Select * 
From Cleaning.dbo.Housing

--Standardize sales date

Select SaleDate, CONVERT(Date,SaleDate)
From Cleaning.dbo.Housing

UPDATE  Housing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Housing
Add SaleDateConverted Date;

UPDATE  Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Regulate Property Address Data

Select *
From Cleaning.dbo.Housing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Cleaning.dbo.Housing a
Join Cleaning.dbo.Housing b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Cleaning.dbo.Housing a
Join Cleaning.dbo.Housing b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking out Address into Individual Column (Address, City, State)


Select PropertyAddress
From Cleaning.dbo.Housing
--Where PropertyAddress is null
--Order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From Cleaning.dbo.Housing



ALTER TABLE Housing
Add PropertySpiltAddress NVarchar(225);

UPDATE  Housing
SET PropertySpiltAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))



ALTER TABLE Housing
Add PropertySpiltCity NVarchar(225);

UPDATE  Housing
SET PropertySpiltCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


SELECT *
FROM Housing



SELECT OwnerAddress
FROM Housing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM Housing


ALTER TABLE Housing
Add OwnerSpiltAddress NVarchar(225);

UPDATE  Housing
SET OwnerSpiltAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE Housing
Add OwnerSpiltCity NVarchar(225);

UPDATE  Housing
SET OwnerSpiltCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE Housing
Add OwnerSpiltState NVarchar(225);

UPDATE  Housing
SET OwnerSpiltState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


--Change Y and N to 'Yes' and 'No' in "sold as vacant" field

SELECT DISTINCT(SoldasVacant), Count(SoldasVacant)
FROM Housing
GROUP BY SoldasVacant
ORDER BY 2



SELECT SoldasVacant
 ,CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
  WHEN SoldasVacant = 'N' THEN 'No'
   ELSE SoldasVacant 
   END
FROM Housing

UPDATE Housing
SET SoldasVacant = CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
  WHEN SoldasVacant = 'N' THEN 'No'
   ELSE SoldasVacant 
   END

   
   -- Remove Duplicate 

   WITH RownumCTE AS (
   SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
   PropertyAddress,
   SaleDate,
   SalePrice,
   LegalReference
   ORDER BY UniqueID
   ) row_num
   FROM Housing
   )
   DELETE
   FROM RownumCTE
   WHERE row_num > 1
   


   --Delete unused Column

   SELECT *
   FROM Housing

   ALTER TABLE Housing
   DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


   ALTER TABLE Housing
   DROP COLUMN SaleDate

