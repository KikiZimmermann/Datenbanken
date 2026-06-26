package net.DBProjekt.dbs.theater.entities;

import java.io.Serializable;
import java.math.BigDecimal;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author Lorenz Froihofer
 * @version $Id: Wein.java 23:9ec636290f6c 2026/01/04 18:07:33 Lorenz Froihofer $
 */
@Entity
@Table(name="WEINE")
public class Wein implements Serializable {
  private static final Logger log = LoggerFactory.getLogger(Wein.class);

  @Id
  @GeneratedValue(strategy=jakarta.persistence.GenerationType.IDENTITY)
  private Integer weinId;

  private BigDecimal preis;
  private String name;
  private Integer jahrgang;
  @Column(name="farbe", columnDefinition="ENUM('Rot', 'Weiß', 'Rose')")
  private String farbe;
  
  @ManyToOne
  @JoinColumn(name="weingut")
  private Erzeuger erzeuger;

  //No arguments constructor required for entity class
  public Wein(){}
  
  public Wein(String name, String farbe, Integer jahrgang, String weingut, BigDecimal preis) {
    this.name = name;
    this.jahrgang = jahrgang;
    this.farbe = farbe;
    this.preis = preis;
    this.erzeuger = new Erzeuger();
    this.erzeuger.setWeingut(weingut);
  }


  public BigDecimal getPreis() {
    return preis;
  }

  public void setPreis(BigDecimal  preis) {
    this.preis = preis;
  }
  /**
   * @return the weinId
   */
  public Integer getWeinId() {
    return weinId;
  }

  /**
   * @param weinId the weinId to set
   */
  public void setWeinId(Integer weinId) {
    this.weinId = weinId;
  }

  /**
   * @return the name
   */
  public String getName() {
    return name;
  }

  /**
   * @param name the name to set
   */
  public void setName(String name) {
    this.name = name;
  }

  /**
   * @return the jahrgang
   */
  public Integer getJahrgang() {
    return jahrgang;
  }

  /**
   * @param jahrgang the jahrgang to set
   */
  public void setJahrgang(Integer jahrgang) {
    this.jahrgang = jahrgang;
  }

  /**
   * @return the farbe
   */
  public String getFarbe() {
    return farbe;
  }

  /**
   * @param farbe the farbe to set
   */
  public void setFarbe(String farbe) {
    this.farbe = farbe;
  }

  /**
   * @return the erzeuger
   */
  public Erzeuger getErzeuger() {
    return erzeuger;
  }

  /**
   * @param erzeuger the erzeuger to set
   */
  public void setErzeuger(Erzeuger erzeuger) {
    this.erzeuger = erzeuger;
  }
}
