SELECT *
FROM Housing_project.dbo.Housing_data


--Standardise date fromat

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Housing_project.dbo.Housing_data

UPDATE Housing_project.dbo.Housing_data
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Housing_data
ADD SaleDateConverted Date

UPDATE Housing_project.dbo.Housing_data
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address Data

SELECT *
FROM Housing_project.dbo.Housing_data
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing_project.dbo.Housing_data a
INNER JOIN Housing_project.dbo.Housing_data b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing_project.dbo.Housing_data a
INNER JOIN Housing_project.dbo.Housing_data b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM Housing_project.dbo.Housing_data

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address_1
FROM Housing_project.dbo.Housing_data


ALTER TABLE Housing_data
ADD PropertySplitAddress Nvarchar(255)

UPDATE Housing_project.dbo.Housing_data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Housing_data
ADD PropertySplitCity Nvarchar(255)

UPDATE Housing_project.dbo.Housing_data
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM Housing_project.dbo.Housing_data

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM Housing_project.dbo.Housing_data

ALTER TABLE Housing_data
ADD OwnerSplitAddress Nvarchar(255)

UPDATE Housing_project.dbo.Housing_data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE Housing_data
ADD OwnerSplitCity Nvarchar(255)

UPDATE Housing_project.dbo.Housing_data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE Housing_data
ADD OwnerSplitState Nvarchar(255)

UPDATE Housing_project.dbo.Housing_data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)



--Change Y and N to Yes and No in the 'Sold as Vacant' filed

SELECT DISTINCT(SoldAsVacant)
FROM Housing_project.dbo.Housing_data

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Housing_project.dbo.Housing_data

UPDATE Housing_project.dbo.Housing_data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num

FROM Housing_project.dbo.Housing_data
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



--Delete Unused Columns
SELECT *
FROM Housing_project.dbo.Housing_data

ALTER TABLE Housing_project.dbo.Housing_data
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate