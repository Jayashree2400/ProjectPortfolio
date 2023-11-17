use projectportfolio

--Data Cleaning in SQL

select * from NashvilleHousing

-----1. Standardize date format

select SaleDateConverted, CONVERT(date,SaleDate)
from NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

--or Method 2

alter table NashvilleHousing
alter column [SaleDate] date 




----2. Populate property address date

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


---- 3. Breaking down address into diffrent fields (City, address, state)

--For Property Address

select propertyaddress,
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
from NashvilleHousing



alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)



alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity  = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select * from NashvilleHousing


--- For Owner Address

select OwnerAddress
from NashvilleHousing


select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress,',','.'),2)



alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



--- 4.Change Y to Yes and N to No in SoldAsVacant Field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end


--- 5. Remove Duplicates

with RowNumCte as(
select *,
ROW_NUMBER() over(
partition by parcelID,
propertyAddress,
SalePrice,
SaleDate,
LegalReference
 order by uniqueID) as row_num
from NashvilleHousing)

select * from
RowNumCte
where row_num > 1



---6. Deleting Unused Columns

select * from
NashvilleHousing

begin tran 

alter table NashvilleHousing
drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

rollback




































