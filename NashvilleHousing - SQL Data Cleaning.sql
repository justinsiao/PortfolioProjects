SELECT *
FROM public.nashville_housing;

------------------------------------------------------------------
-- Populate Property Address data

-- Info about addresses that are NULL

SELECT *
FROM nashville_housing
-- WHERE propertyaddress IS NULL
ORDER BY parcelid;

-- Self-join to determine the right address to insert into NULL values.

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress
FROM nashville_housing a
JOIN nashville_housing b
ON a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

-- Changing the NULLS to specific address based on the same parcel id using self-join

UPDATE nashville_housing
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housing a
JOIN nashville_housing b
ON a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

-- Looking propertyaddress column

SELECT propertyaddress
FROM nashville_housing;

-- Splitting the address by the comma delimiter

SELECT
SUBSTRING(propertyaddress, 1, STRPOS(propertyaddress, ',')-1) as address,
	SUBSTRING(propertyaddress, STRPOS(propertyaddress, ',')+1, LENGTH(propertyaddress)) as address
FROM nashville_housing;

-- Adding columns for split address

ALTER TABLE nashville_housing
ADD property_split_address VARCHAR(255);
ALTER TABLE nashville_housing
ADD property_split_city VARCHAR(255);

-- Updating table to insert the value into the new columns

UPDATE nashville_housing
SET property_split_address = SUBSTRING(propertyaddress, 1, STRPOS(propertyaddress, ',')-1);

UPDATE nashville_housing
SET property_split_city = SUBSTRING(propertyaddress, STRPOS(propertyaddress, ',')+1, LENGTH(propertyaddress));

-- Splitting the owner address and add new columns to place the values

SELECT owneraddress
FROM nashville_housing;

SELECT
SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 1),
SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 2),
SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 3)
FROM nashville_housing;

-- Add new columns for owner address and adding its corresponding values

ALTER TABLE nashville_housing
ADD owner_split_address VARCHAR(255);
ALTER TABLE nashville_housing
ADD owner_split_city VARCHAR(255);
ALTER TABLE nashville_housing
ADD owner_split_state VARCHAR(255);

UPDATE nashville_housing
SET owner_split_address = SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 1);

UPDATE nashville_housing
SET owner_split_city = SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 2);

UPDATE nashville_housing
SET owner_split_state = SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 3);

------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM nashville_housing
GROUP BY soldasvacant;

-- Using case statement to change Y to yes and N to no, remain if otherwise

SELECT soldasvacant,
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	 WHEN soldasvacant = 'N' THEN 'No'
	 ELSE soldasvacant
END
FROM nashville_housing;

-- Updating the table to insert the new data

UPDATE nashville_housing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	 					WHEN soldasvacant = 'N' THEN 'No'
	 					ELSE soldasvacant
					END;
					
------------------------------------------------------------------
-- Removing duplicates

-- Creating table to determine rows with duplicates

DROP TABLE IF EXISTS row_num_new;
CREATE TABLE row_num_new(
	UniqueID INT,
	ParcelID VARCHAR(255),
	LandUse VARCHAR(255),
	PropertyAddress VARCHAR(255),
	SaleDate DATE,
	SalePrice INT,
	LegalReference VARCHAR(255),
	SoldAsVacant VARCHAR(255),
	OwnerName VARCHAR(255),
	OwnerAddress VARCHAR(255),
	Acreage DOUBLE PRECISION,
	TaxDistrict VARCHAR(255),
	LandValue INT,
	BuildingValue INT,
	TotalValue INT,
	YearBuilt VARCHAR(255),
	Bedrooms INT,
	FullBath INT,
	HalfBath INT,
	property_split_address VARCHAR(255),
	propert_split_city VARCHAR(255),
	owner_split_address VARCHAR(255),
	owner_split_city VARCHAR(255),
	owner_split_state VARCHAR(255),
	row_num BIGINT
);
INSERT INTO row_num_new
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress, saleprice, legalreference ORDER BY uniqueid) row_num
FROM nashville_housing;

-- Selecting the new table created with duplicates

SELECT *
FROM row_num_new
WHERE row_num > 1;

-- Delete all the duplicate rows and then running the previous code to determine if there's no duplicates left

DELETE
FROM row_num_new
WHERE row_num > 1;

------------------------------------------------------------------
-- Delete unused columns

SELECT *
FROM row_num_new;

ALTER TABLE row_num_new
DROP COLUMN owneraddress, 
DROP COLUMN taxdistrict, 
DROP COLUMN propertyaddress, 
DROP COLUMN saledate
DROP COLUMN;