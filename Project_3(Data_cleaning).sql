
/*
Cleaning Data in SQL Queries
*/


SELECT *
FROM PortfolioProject_3.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject_3.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


-- or --

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject_3.dbo.NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProject_3.dbo.NashvilleHousing
WHERE PropertyAddress is NULL
ORDER BY ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject_3.dbo.NashvilleHousing a
JOIN PortfolioProject_3.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID  -- where both id's are same in the data
	AND a.[UniqueID ] <> b.[UniqueID ] -- unique id is 'unique', so it's not equal to
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject_3.dbo.NashvilleHousing a
JOIN PortfolioProject_3.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject_3.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address -- "it's looking in 'property adress'" then "1 for the starting value in property adress" then CHARINDEX(',', PropertyAddress) for 'at position' means it's going untill comma, -1 to delete one in position to remove 'comma'
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address -- starting from CHARINDEX(',', PropertyAddress) + 1 [+1 to remove comma) upto LENGTH of PROPERTY ADDRESS

From PortfolioProject_3.dbo.NashvilleHousing

                         -- adding two new columns PropertySplitAddress and PropertySplitCity by splitting PropertyAddress to the main data         
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



Select *
From PortfolioProject_3.dbo.NashvilleHousing



Select OwnerAddress
From PortfolioProject_3.dbo.NashvilleHousing



Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)  -- parsname does things backword
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject_3.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject_3.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant)
From PortfolioProject_3.dbo.NashvilleHousing


Select Distinct(SoldAsVacant), Count(SoldAsVacant) 
From PortfolioProject_3.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject_3.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

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
					) row_num

From PortfolioProject_3.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject_3.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns(that we no longer want to see)



Select *
From PortfolioProject_3.dbo.NashvilleHousing


ALTER TABLE PortfolioProject_3.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


