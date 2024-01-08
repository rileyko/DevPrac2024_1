/**
 * @description       :
 * @author            : Woolim Ko
 * @group             : Trestle
 * @last modified on  : 01-08-2024
 * @last modified by  : Woolim Ko
 **/
import { LightningElement, api } from "lwc";
import getQueryResult1 from "@salesforce/apex/DuplicateController.getQueryResult";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import TABULATOR from "@salesforce/resourceUrl/TabulatorFile";

//const tabledata = [
//  {
//    name: "Woolim Sample1",
//    phone: "01096522480",
//    ownerId: "005Ho00000AzxAIIAZ"
//  },
//  {
//    name: "Woolim Sample2",
//    phone: "01096522480",
//    ownerId: "005Ho00000AzxAIIAZ"
//  },
//  {
//    name: "Woolim Sample3",
//    phone: "01096522480",
//    ownerId: "005Ho00000AzxAIIAZ"
//  }
//];

export default class duplicatList extends LightningElement {
  cols = [
    {
      title: "이름",
      field: "name"
    },
    {
      title: "회사용 전화번호",
      field: "phone"
    },
    {
      title: "담당 세일즈",
      field: "ownerId"
    }
  ];
  /* --------------------------------------------------------------------------------------------------------
    * Flag
    -------------------------------------------------------------------------------------------------------- */
  /**
   * Flag whether tabulator initialized
   * @memberof Modal
   * @private
   * @type {boolean}
   */
  tabulatorInitialized = false;

  /* --------------------------------------------------------------------------------------------------------
   * Attribute
   -------------------------------------------------------------------------------------------------------- */
  @api recordId;
  table;
  test;

  /* --------------------------------------------------------------------------------------------------------
     * Lifecycle
    -------------------------------------------------------------------------------------------------------- */
  connectedCallback() {
    console.log("connected===============");
    console.log(this.recordId);
  }

  renderedCallback() {
    console.log("rendered===============");
    this.tabulatorInitialized = true;

    Promise.all([
      loadScript(this, TABULATOR + "/tabulator-master/dist/js/tabulator.js"),
      loadStyle(this, TABULATOR + "/tabulator-master/dist/css/tabulator.css")
    ])
      .then(() => {
        this.getQueryResult();
      })
      .catch((error) => {
        console.error(error);
      });
  }

  /* --------------------------------------------------------------------------------------------------------
     * Apex
    -------------------------------------------------------------------------------------------------------- */

  async getQueryResult() {
    this.test = await getQueryResult1();
    this.initializeTabulator();
  }

  /* --------------------------------------------------------------------------------------------------------
     * Method
    -------------------------------------------------------------------------------------------------------- */
  /**
   * Initialize tabulator component
   * @memberof TabulatorExample
   * @private
   *
   * @example
   */
  initializeTabulator() {
    // eslint-disable-next-line no-undef
    this.table = new Tabulator(this.template.querySelector("div.tabulator"), {
      //  data: tabledata, //load row data from array
      data: this.test, //load row data from array
      layout: "fitColumns", //fit columns to width of table
      //  placeholder: "No Data Available",
      //  responsiveLayout: "hide", //hide columns that dont fit on the table
      //  tooltips: true, //show tool tips on cells
      //  addRowPos: "top", //when adding a new row, add it to the top of the table
      //  history: true, //allow undo and redo actions on the table
      //  pagination: "local", //paginate the data
      //  paginationSize: 7, //allow 7 rows per page of data
      //  paginationCounter: "rows", //display count of paginated rows in footer
      //  movableColumns: true, //allow column order to be changed

      //  initialSort: [{ column: "name", dir: "asc" }],
      columns: this.cols
    });
  }

  /* --------------------------------------------------------------------------------------------------------
     * Callback
    -------------------------------------------------------------------------------------------------------- */
  cellEditing(cell) {
    console.log("= = = cellEditing = = = ");
    console.log("getOldValue: " + cell.getOldValue());
    console.log("getInitialValue: " + cell.getInitialValue());
    console.log("getValue: " + cell.getValue());
  }

  cellEdited(cell) {
    console.log("= = = cellEdited = = = ");
    console.log("getOldValue: " + cell.getOldValue());
    console.log("getInitialValue: " + cell.getInitialValue());
    console.log("getValue: " + cell.getValue());
  }
}
