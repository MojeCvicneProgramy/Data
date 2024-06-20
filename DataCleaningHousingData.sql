/*

Data Cleaning in SQL

*/


Select *
From Portfolio.dbo.Housing

--------------------------------------------------------------------------------------------------------------------------

-- Zmena formátu dátumu z datetime na date


Select saleDateConverted, CONVERT(Date,SaleDate)
From Portfolio.dbo.Housing


Update Housing
SET SaleDate = CONVERT(Date,SaleDate)

-- Ak by nefungovalo, skúsiť takto

ALTER TABLE Housing
Add SaleDateConverted Date;

Update Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Niektoré adresy PropertyAddress boli prázdne, ale vieme ich ParcelID a k tomu je často niekde vypísaná adresa, ktorá musí byť rovnaká. Takže urobime JOIN z tej istej tabuľky

Select *
From Portfolio.dbo.Housing
--Where PropertyAddress is null
order by ParcelID


-- príprava funkcie pomocou SELECT - aby sme overili čo vyberie a zmení
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)  -- ISNULL() - ak a.PropertyAddress je NULL, tak vpíš b.PropertyAddress
From Portfolio.dbo.Housing a
JOIN Portfolio.dbo.Housing b
	on a.ParcelID = b.ParcelID  -- rovnaké čísla parciel dáme dokopy
	AND a.[UniqueID ] <> b.[UniqueID ]  -- ale tak aby UniqueID neboli tie isté, inak by mohlo napárovať znovu to isté NULL
Where a.PropertyAddress is null  -- pre tie prípady kde je prázdna adresa

  
-- UPDATE tabuľky
Update a  -- zmeniť tabuľku "a" (použiť alias)
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.Housing a
JOIN Portfolio.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Rozdelenie textu adresy na stĺpce s hodnotami ulica, mesto, štát


Select PropertyAddress
From Portfolio.dbo.Housing
--Where PropertyAddress is null
--order by ParcelID

  
-- príprava funkcie pomocou SELECT - aby sme overili čo vyberie a zmení
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address       -- časť textu (SUBSTRING) z PropertyAddress od pozície 1 po posledný znak pred čiarkou
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2 , LEN(PropertyAddress)) as Address     -- časť textu z PropertyAddress od pozície 2 hneď za čiarkou po posledný znak (presné číslo získame tak že spočítame počet znakov funkciou LEN

From Portfolio.dbo.Housing

  
-- zmena tabuľky - oddelenie Adresy
ALTER TABLE Housing
Add PropertySplitAddress Nvarchar(255);

Update Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

-- zmena tabuľky - oddelenie mesta
ALTER TABLE Housing
Add PropertySplitCity Nvarchar(255);

Update Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



-- výsledok
Select *
From Portfolio.dbo.Housing




-- druhý spôsob rozdelenia adresy
Select OwnerAddress
From Portfolio.dbo.Housing

--  PARSENAME() hľadá bodku v OwnerAddress, n-tú v poradí odzadu
-- keďže tam nemáme bodku, ale čiarku, tak ju najprv nahradíme pomocou REPLACE()
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Portfolio.dbo.Housing



ALTER TABLE Housing
Add OwnerSplitAddress Nvarchar(255);

Update Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Housing
Add OwnerSplitCity Nvarchar(255);

Update Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Housing
Add OwnerSplitState Nvarchar(255);

Update Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Portfolio.dbo.Housing




--------------------------------------------------------------------------------------------------------------------------


-- Zmena Y a N na Yes a No v stĺpci "Sold as Vacant"


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio.dbo.Housing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portfolio.dbo.Housing


Update Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


-- PARTITION BY dá dokopy riadky s rovnakými ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
-- 	ROW_NUMBER() OVER () priradí čísla riadkov
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
					) row_num    -- názov stĺpca

From Portfolio.dbo.Housing
)
  
Select *      -- použijeme SELECT na prípravu a skontrolovanie dát ktoré chceme zmazať
-- DELETE     -- potom v ďalšom kroku zmeníme len SELECT * na DELETE a spustíme premazanie zduplikovaných dát
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



Select *
From Portfolio.dbo.Housing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From Portfolio.dbo.Housing


ALTER TABLE Portfolio.dbo.Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


