SET SERVEROUTPUT ON;

--cz. 1
--------------------------------------------------traveler assistance package
CREATE OR REPLACE PACKAGE traveler_assistance_package AS
    --------------------------------------------------typy
    TYPE tr_countries IS RECORD(
        country_name    countries.country_name%TYPE,
        region_name     regions.region_name%TYPE,
        currency_name   currencies.currency_name%TYPE
    );
    TYPE t_countries IS TABLE OF tr_countries INDEX BY PLS_INTEGER;
    
    TYPE tr_country_languages IS RECORD(
       country_name         countries.country_name%TYPE,
       language_name        languages.language_name%TYPE,
       official_language    spoken_languages.official%TYPE
    );
    TYPE t_country_languages IS TABLE OF tr_country_languages INDEX BY PLS_INTEGER;
    
    --------------------------------------------------procedury
    PROCEDURE country_demographics(
        p_country_name  IN  VARCHAR2
    );
    
    PROCEDURE find_region_and_currency(
        p_country_name  IN  VARCHAR2,
        p_country       OUT tr_countries
    );
    
    PROCEDURE countries_in_same_region(
        p_region_name   IN  VARCHAR2,
        p_countries     OUT t_countries 
    );
    
    PROCEDURE print_region_array(
        p_countries IN  t_countries
    );
    
    PROCEDURE country_languages(
        p_country_name      IN  VARCHAR2,
        p_country_languages OUT t_country_languages
    );
    
    PROCEDURE print_language_array(
        p_country_languages IN  t_country_languages
    );
END traveler_assistance_package;
/

--------------------------------------------------body
CREATE OR REPLACE PACKAGE BODY traveler_assistance_package AS
    --------------------------------------------------country demographics
    PROCEDURE country_demographics(
        p_country_name  IN  VARCHAR2
    ) AS BEGIN
        FOR country IN (
            SELECT *
            FROM countries
            WHERE LOWER(country_name) = LOWER(p_country_name)
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(country.country_name || ',  '
            || country.location || ', ' || country.capitol || ', '
            || country.population || ', ' || country.airports || ', '
            || country.climate);
        END LOOP;
    END country_demographics;
    
    --------------------------------------------------find refion and currency
    PROCEDURE find_region_and_currency(
        p_country_name  IN  VARCHAR2,
        p_country       OUT tr_countries
    ) AS BEGIN
        SELECT co.country_name, r.region_name, cu.currency_name
        INTO p_country
        FROM countries co, regions r, currencies cu
        WHERE LOWER(co.country_name) = LOWER(p_country_name)
        AND co.region_id = r.region_id
        AND co.currency_code = cu.currency_code;
    END find_region_and_currency;

    --------------------------------------------------countries in same region
    PROCEDURE countries_in_same_region(
        p_region_name   IN  VARCHAR2,
        p_countries     OUT t_countries 
    ) AS 
        CURSOR v_countries_in_same_region IS
            SELECT co.country_name, r.region_name, cu.currency_name
            FROM countries co, regions r, currencies cu
            WHERE LOWER(r.region_name) = LOWER(p_region_name)
            AND co.region_id = r.region_id
            AND co.currency_code = cu.currency_code;
        v_i PLS_INTEGER;
    BEGIN
        v_i := 1;
        
        FOR l_country IN v_countries_in_same_region LOOP
            p_countries(v_i) := l_country;
            v_i := v_i+1;
        END LOOP;
    END countries_in_same_region;
    
    --------------------------------------------------print region array
    PROCEDURE print_region_array(
        p_countries IN  t_countries
    ) AS
        v_i PLS_INTEGER;
    BEGIN
        v_i := p_countries.FIRST;
    
        WHILE v_i IS NOT NULL LOOP
            DBMS_OUTPUT.PUT_LINE(p_countries(v_i).country_name || ', '
            || p_countries(v_i).region_name || ', ' || p_countries(v_i).currency_name);
        
            v_i := p_countries.NEXT(v_i);
        END LOOP;
    END print_region_array;
    
    --------------------------------------------------country languages
    PROCEDURE country_languages(
        p_country_name      IN  VARCHAR2,
        p_country_languages OUT t_country_languages
    ) AS
        CURSOR v_country_languages IS
            SELECT c.country_name, l.language_name, sl.official
            FROM countries c, languages l, spoken_languages sl
            WHERE LOWER(c.country_name) = LOWER(p_country_name)
            AND c.country_id = sl.country_id
            AND sl.language_id = l.language_id;
        v_i PLS_INTEGER;
    BEGIN
        v_i := 1;
        
        FOR l_country_language IN v_country_languages LOOP
            p_country_languages(v_i) := l_country_language;
            v_i := v_i+1;
        END LOOP;
    END country_languages;
    
    --------------------------------------------------print language array
    PROCEDURE print_language_array(
        p_country_languages IN  t_country_languages
    ) AS
        v_i PLS_INTEGER;
    BEGIN
        v_i := p_country_languages.FIRST;
    
        WHILE v_i IS NOT NULL LOOP
            DBMS_OUTPUT.PUT_LINE(p_country_languages(v_i).country_name || ', '
            || p_country_languages(v_i).language_name || ', '
            || p_country_languages(v_i).official_language);
            
            v_i := p_country_languages.NEXT(v_i);
        END LOOP;
    END print_language_array;
END traveler_assistance_package;
/

--cz. 2
--------------------------------------------------traveler admin package
CREATE OR REPLACE PACKAGE traveler_admin_package AS
    --------------------------------------------------typy    
    TYPE tr_dependent_objects IS RECORD(
        name            user_dependencies.name%TYPE,
        type            user_dependencies.type%TYPE,
        referenced_name user_dependencies.referenced_name%TYPE,
        referenced_type user_dependencies.referenced_type%TYPE
    );
    TYPE t_dependent_objects IS TABLE OF tr_dependent_objects INDEX BY PLS_INTEGER;
    
    --------------------------------------------------procedury
    PROCEDURE display_disabled_triggers;
    
    PROCEDURE print_dependent_objects(
        p_objects IN t_dependent_objects
    );
    
    --------------------------------------------------funkcje
    FUNCTION all_dependent_objects(
        p_object_name IN VARCHAR2
    ) RETURN t_dependent_objects;
END traveler_admin_package;
/

--------------------------------------------------body
CREATE OR REPLACE PACKAGE BODY traveler_admin_package AS
    --------------------------------------------------display disabled triggers
    PROCEDURE display_disabled_triggers AS
        CURSOR v_triggers IS
            SELECT trigger_name
            FROM user_triggers
            WHERE status = 'DISABLED';
    BEGIN
        FOR l_trigger IN v_triggers LOOP
            DBMS_OUTPUT.PUT_LINE(l_trigger.trigger_name ||' is off');
        END LOOP;
    END display_disabled_triggers;
    
    --------------------------------------------------print dependent objects
    PROCEDURE print_dependent_objects(
        p_objects IN t_dependent_objects
    ) AS
        v_i PLS_INTEGER;
    BEGIN
        v_i := p_objects.FIRST;
    
        WHILE v_i IS NOT NULL LOOP
            DBMS_OUTPUT.PUT_LINE(p_objects(v_i).name || ' '
            || p_objects(v_i).type || ' ' || p_objects(v_i).referenced_name || ' '
            || p_objects(v_i).referenced_type);
            
            v_i := p_objects.NEXT(v_i);
        END LOOP;
    END print_dependent_objects;
    
    --------------------------------------------------all dependent objects
    FUNCTION all_dependent_objects(
        p_object_name IN VARCHAR2
    ) RETURN t_dependent_objects AS
        CURSOR v_objects IS
            SELECT name, type, referenced_name, referenced_type
            FROM user_dependencies
            WHERE LOWER(referenced_name) = LOWER(p_object_name);
        v_objects_return t_dependent_objects;
        v_i PLS_INTEGER;
    BEGIN
        v_i := 1;
        
        FOR v_object IN v_objects LOOP
            v_objects_return(v_i) := v_object;
            v_i := v_i+1;
        END LOOP;
        
        RETURN v_objects_return;
    END all_dependent_objects;
END traveler_admin_package;
/
    