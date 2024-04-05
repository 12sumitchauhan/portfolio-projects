create database project;
use project;

select *
from project.dbo.NashvilleHousing;

-- cleaning data in SQL queries


-- standarise date format

select saledateconverted, CONVERT(date,saledate)
from project.dbo.NashvilleHousing;


alter table NashvilleHousing
add saledateconverted date;

update NashvilleHousing
set saledateconverted=CONVErt(date,saledate); 


-- property address data

select *
from project.dbo.NashvilleHousing
order by ParcelID;
--where PropertyAddress is null;

select a.parcelid,a.PropertyAddress,b.parcelid,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from project.dbo.NashvilleHousing a 
join  project.dbo.NashvilleHousing b
	on a.parcelid=b.parcelid
	and a.[uniqueid]<>b.[uniqueid]
where a.PropertyAddress is null;

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from project.dbo.NashvilleHousing a 
join  project.dbo.NashvilleHousing b
	on a.parcelid=b.parcelid
	and a.[uniqueid]<>b.[uniqueid]
where a.PropertyAddress is null;


-- Breaking out address into individual columns (address,city,state)

select PropertyAddress
from project.dbo.NashvilleHousing;


select 
SUBSTRING(Propertyaddress, 1, CHARINDEX(',',Propertyaddress) -1 )as address,
SUBSTRING(Propertyaddress, CHARINDEX(',',Propertyaddress) +1,len(propertyaddress))as city
from project.dbo.NashvilleHousing;

alter table NashvilleHousing
add property_splitaddress nvarchar(255);


update NashvilleHousing
set property_splitaddress=SUBSTRING(Propertyaddress, 1, CHARINDEX(',',Propertyaddress) -1 ); 

alter table NashvilleHousing
add property_splitcity nvarchar(255);


update NashvilleHousing
set property_splitcity=SUBSTRING(Propertyaddress, CHARINDEX(',',Propertyaddress) +1,len(propertyaddress)); 

select property_splitaddress,property_splitcity
from project.dbo.NashvilleHousing;




select owneraddress
from project.dbo.NashvilleHousing;

select
PARSENAME(replace(owneraddress,',','.'),3)
,PARSENAME(replace(owneraddress,',','.'),2)
,PARSENAME(replace(owneraddress,',','.'),1)
from project.dbo.NashvilleHousing;


alter table NashvilleHousing
add Owner_splitaddress nvarchar(255);
update NashvilleHousing
set Owner_splitaddress=PARSENAME(replace(owneraddress,',','.'),3); 

alter table NashvilleHousing
add Owner_splitcity nvarchar(255);
update NashvilleHousing
set Owner_splitcity=PARSENAME(replace(owneraddress,',','.'),2); 

alter table NashvilleHousing
add Owner_splitstate nvarchar(255);

update NashvilleHousing
set Owner_splitstate=PARSENAME(replace(owneraddress,',','.'),1); 

select *
from project.dbo.NashvilleHousing;



-- change Y and N to yes and no in 'sold as vacant' field

select distinct(soldasvacant),count(soldasvacant)
from project.dbo.NashvilleHousing
Group by soldasvacant
order by 2;

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else soldasvacant
	end
from project.dbo.NashvilleHousing


alter table NashvilleHousing
add SoldAsVacant_new nvarchar(255);

update NashvilleHousing
set SoldAsVacant_new=case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else soldasvacant
	end; 

-- Remove duplicates
with rownumcte as (
select *,
	ROW_NUMBER() over (partition by Parcelid,Propertyaddress,Saleprice,Saledate,legalreference
	order by uniqueid)row_num

from project.dbo.NashvilleHousing
--order by ParcelID
)

delete 
from rownumcte
where row_num>2;
--order by PropertyAddress;

select *
from rownumcte
where row_num>2
order by PropertyAddress;


-- delete unused data

select *
from project.dbo.NashvilleHousing

alter table project.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress;

alter table project.dbo.NashvilleHousing
drop column saledate;