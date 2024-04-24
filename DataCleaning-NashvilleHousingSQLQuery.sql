--Cleaning Data in SQL Queries - Nashville Housing Dataset

Select *
from PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, Convert(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

Select *
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null


Select *
from PortfolioProject.dbo.NashvilleHousing
order by ParcelID

Select t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, ISNULL(t1.PropertyAddress, t2.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing t1
Join PortfolioProject.dbo.NashvilleHousing t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID] <> t2.[UniqueID]
where t1.PropertyAddress is null

-- Hence we are removing null values in Property Address

Update t1
SET PropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing t1
Join PortfolioProject.dbo.NashvilleHousing t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID] <> t2.[UniqueID]
Where t1.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
--CHARINDEX bassically gives a number(no. of spaces needed), so the -1 here
--is used to remove the comma(,) from the Address 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) as Address
-- used to get values after the comma(,)
from PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-- Now we have added the split columns to the data
Select *
from PortfolioProject.dbo.NashvilleHousing

--Now for owners address 
Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

--Trying Parsename instead of substring to split the adderss
-- Its easier
--ParseName lookes for periods and not (,)'s or commas in this case

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
from PortfolioProject.dbo.NashvilleHousing
--It takes Statename, Parse word does things backwards

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
from PortfolioProject.dbo.NashvilleHousing
--But this will give the address backwards, hence we should just reverse it

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
from PortfolioProject.dbo.NashvilleHousing
-- Now we obtained the order we wanted and its easier than substring


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

-- For easy Coding type all alter first and then update stmts
--But for visual purposes this is better

Select *
from PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant ='Y' Then 'Yes'
	   When SoldAsVacant ='N' Then 'No'
	   ELSE SoldAsVacant
	   END
from 

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant ='Y' Then 'Yes'
	   When SoldAsVacant ='N' Then 'No'
	   ELSE SoldAsVacant
	   END

Select SoldAsVacant
from PortfolioProject.dbo.NashvilleHousing

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

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

From PortfolioProject.dbo.NashvilleHousing
)

Select *
--Used DELETE instead of select * and delete the duplicated data
from RowNumCTE
where row_num > 1
--order by PropertyAddress


Select *
From PortfolioProject.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------




