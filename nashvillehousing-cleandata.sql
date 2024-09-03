-- Cleaning data in SQL Queries

select * from NashvilleHousing
----------------------------------------------
-- Standardize Date Formate

select SaleDateConverted, Convert(date,SaleDate)
from NashvilleHousing

update NashvilleHousing
set SaleDate = Convert(date,SaleDate) --- by this method it dosent work

Alter table NashvilleHousing
add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = Convert(date,SaleDate)

-----------------
--Populate Property Address data

select *
from NashvilleHousing
--where PropertyAddress is null
order by parcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress = isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-----------------
--Breaking out address into individual Columns(address, city, state)

select PropertyAddress
from NashvilleHousing

select SUBSTRING(propertyaddress,1,charindex(',', PropertyAddress) -1) as address -- to remove the coma
, SUBSTRING(propertyaddress,charindex(',', PropertyAddress) +1, len(propertyaddress)) as address
from NashvilleHousing

alter table NashvilleHousing
add PropertySpliteAddress nvarchar(255)

update NashvilleHousing
set PropertySpliteAddress = SUBSTRING(propertyaddress,1,charindex(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySpliteCity nvarchar(255)

update NashvilleHousing
set PropertySpliteCity = SUBSTRING(propertyaddress,
charindex(',', PropertyAddress) +1, len(propertyaddress))

select owneraddress
from NashvilleHousing

select PARSENAME(replace(owneraddress,',','.'), 1), --- parsname only works with dots
 PARSENAME(replace(owneraddress,',','.'), 2),
 PARSENAME(replace(owneraddress,',','.'), 3)

from NashvilleHousing

alter table NashvilleHousing
add OwnerSpliteAddress nvarchar(255)

update NashvilleHousing
set OwnerSpliteAddress = PARSENAME(replace(owneraddress,',','.'), 3)

alter table NashvilleHousing
add OwnerSpliteCity nvarchar(255)

update NashvilleHousing
set OwnerSpliteCity = PARSENAME(replace(owneraddress,',','.'), 2)

alter table NashvilleHousing
add OwnerSpliteState nvarchar(255)

update NashvilleHousing
set OwnerSpliteState = PARSENAME(replace(owneraddress,',','.'), 1)

---------------------
--change y and n to yes and no in 'sold as vacant' field

select distinct(SoldAsVacant)
from NashvilleHousing

select soldasvacant, count(soldasvacant)
from NashvilleHousing
group by soldasvacant

select soldasvacant , case when soldasvacant = 'y' then 'Yes'
when soldasvacant ='n' then 'No'
else soldasvacant
end
from NashvilleHousing

update NashvilleHousing
SET soldasvacant = CASE 
                        WHEN soldasvacant = 'y' THEN 'Yes' 
                        when soldasvacant ='n' then 'No'
						else SoldAsVacant
                   END

-----------------------------
-- remove duplicates
With RowNumCte as (
select  *, 
ROW_NUMBER() over (Partition by parcelid, 
propertyaddress, 
saleprice, 
saledate, 
legalreference
order by 
uniqueid) row_num
from NashvilleHousing 
--order by ParcelID
)
-- delete from rownumcte where row_num>1
select * from RowNumCte
where row_num>1

-----------------------------------
--delete unused columns

alter table nashvillehousing
drop column saledate,owneraddress, taxdistrict,propertyaddress

select * from NashvilleHousing


