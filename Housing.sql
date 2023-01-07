Select *
From PortfolioProject..NashvilleHousing

-- standardize date format
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date
Select SaleDate
From PortfolioProject..NashvilleHousing


-- populate property address data (NULL fields)
Select PropertyAddress
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- break out property address into individual columns (address, city)
Select PropertyAddress
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertyStreetAddress Nvarchar(255),
	PropertyCity Nvarchar(255)
Update NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
Update NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- break out owner address into individual columns (address, city, state)
Select OwnerAddress
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerStreetAddress Nvarchar(255),
	OwnerCity Nvarchar(255),
	OwnerState Nvarchar(255)
Update NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
Update NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
Update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- change Y/N to Yes/No in 'Sold as Vacant' to unify
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group BY SoldAsVacant
order by 2

Update NashvilleHousing
SET SoldAsVacant = 
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


-- remove duplicates
; WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
)
DELETE --Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


-- delete unused columns
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

Select *
From PortfolioProject..NashvilleHousing