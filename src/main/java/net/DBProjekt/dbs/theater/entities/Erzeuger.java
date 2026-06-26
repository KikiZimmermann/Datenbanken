package net.DBProjekt.dbs.theater.entities;

import java.io.Serializable;
import java.util.List;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author Lorenz Froihofer
 * @version $Id: Erzeuger.java 23:9ec636290f6c 2026/01/04 18:07:33 Lorenz Froihofer $
 */
@Entity
@Table(name = "ERZEUGER")
public class Erzeuger implements Serializable {
  private static final Logger log = LoggerFactory.getLogger(Erzeuger.class);
  
  @Id
  private String weingut;
  private String anbaugebiet;
  private String region;

  @OneToMany(mappedBy="erzeuger")
  private List<Wein> weine;
  
  /**
   * @return the weingut
   */
  public String getWeingut() {
    return weingut;
  }

  /**
   * @param weingut the weingut to set
   */
  public void setWeingut(String weingut) {
    this.weingut = weingut;
  }

  /**
   * @return the anbaugebiet
   */
  public String getAnbaugebiet() {
    return anbaugebiet;
  }

  /**
   * @param anbaugebiet the anbaugebiet to set
   */
  public void setAnbaugebiet(String anbaugebiet) {
    this.anbaugebiet = anbaugebiet;
  }

  /**
   * @return the region
   */
  public String getRegion() {
    return region;
  }

  /**
   * @param region the region to set
   */
  public void setRegion(String region) {
    this.region = region;
  }

  /**
   * @return the weine
   */
  public List<Wein> getWeine() {
    return weine;
  }

  /**
   * @param weine the weine to set
   */
  public void setWeine(List<Wein> weine) {
    this.weine = weine;
  }
}
