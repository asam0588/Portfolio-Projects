Select Distinct SoldAsVacant from PortfolioProject..NashvilleHousing

----------------------------------------------Selecting Sale Date---------------------------------------

Select SaleDate from PortfolioProject..NashvilleHousing

---Removing the timestamp from date

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

----The above code didn't update the SaleDate column in the table so trying a different approach

ALTER TABLE PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Checking to see if the above code works

Select SaleDate, SaleDateConverted from PortfolioProject..NashvilleHousing

-- And it does

--- Working with Property Address and looking at Null values

Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

--Next some of these Null values can be replaced with Property addresses having ParcelID so will use a self join 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--- Populating the property address into the Null columns
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

---Separating the property address into individual columns (Address, City, State)


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,   -- Using -1 to remove the trailing ',' from the output address
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address -- Using +1 to remove the leading ','
From PortfolioProject.dbo.NashvilleHousing

----Updating out table to accomodate the above changes

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertyAddressNew nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertyAddressNew = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add CityAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET CityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing

-----Working with Owner Address

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


-- Using Parsename function for splitting the address but few things to be kept in mind
-- Parsename works with periods'.' only and not commas so converting all commas in address to periods using Replace
-- Parsename works backwords i.e: gives the last string before demiliter first and then works its way to the beginning which is why used 3,2,1 to preserve address order
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

--------Finally updating the table----

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
Add OwnerAddressNew Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerAddressNew = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

---Select * from PortfolioProject.dbo.NashvilleHousing--


--- Cleaning the SoldAsVacant column which has ambigous entries instead of just Yes and No

Select Distinct SoldAsVacant from PortfolioProject..NashvilleHousing

--- Converting the diffrent entry values into Yes and No wit a case statement

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

---Updating the table to add new column---

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

---Remove Duplicates----

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

From PortfolioProject.dbo.NashvilleHousing 
)

Delete 
From RowNumCTE
Where row_num > 1

---Deleting Unused columns-----

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

----------Checking the final table after removing dupliactes and geeting rid of unused columns

Select *
From PortfolioProject.dbo.NashvilleHousing