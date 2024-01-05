/**
 * @description       :
 * @author            : Woolim Ko
 * @group             : Trestle
 * @last modified on  : 01-05-2024
 * @last modified by  : Woolim Ko
 **/
import { LightningElement, api } from "lwc";
import getQueryResult from "@salesforce/apex/DuplicateController.getQueryResult";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";

import TABULATOR from "@salesforce/resourceUrl/TabulatorFile";

const tabledata = [
  {
    Name: "Woolim Sample1",
    Phone: "01096522480",
    OwnerId: "005Ho00000AzxAIIAZ"
  },
  {
    Name: "Woolim Sample2",
    Phone: "01096522480",
    OwnerId: "005Ho00000AzxAIIAZ"
  },
  {
    Name: "Woolim Sample3",
    Phone: "01096522480",
    OwnerId: "005Ho00000AzxAIIAZ"
  }
];

export default class duplicatList extends LightningElement {
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
  tabulatorData;

  /* --------------------------------------------------------------------------------------------------------
     * Lifecycle
    -------------------------------------------------------------------------------------------------------- */
  connectedCallback() {
    console.log("connected===============");
    this.getQueryResult();
    console.log(this.recordId + " is null");
  }

  renderedCallback() {
    if (this.tabulatorInitialized) {
      return;
    }
    this.tabulatorInitialized = true;

    Promise.all([
      loadScript(this, TABULATOR + "/tabulator-master/dist/js/tabulator.js"),
      loadStyle(this, TABULATOR + "/tabulator-master/dist/css/tabulator.css")
    ])
      .then(() => {
        this.initializeTabulator();
      })
      .catch((error) => {
        console.error(error);
      });
  }

  /* --------------------------------------------------------------------------------------------------------
     * Apex
    -------------------------------------------------------------------------------------------------------- */
  getQueryResult() {
    getQueryResult().then((result) => {
      this.tabulatorData = result.resultList;
      console.log(result.result);
    });
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
      data: tabledata, //load row data from array
      layout: "fitColumns", //fit columns to width of table
      responsiveLayout: "hide", //hide columns that dont fit on the table
      tooltips: true, //show tool tips on cells
      addRowPos: "top", //when adding a new row, add it to the top of the table
      history: true, //allow undo and redo actions on the table
      pagination: "local", //paginate the data
      paginationSize: 7, //allow 7 rows per page of data
      paginationCounter: "rows", //display count of paginated rows in footer
      movableColumns: true, //allow column order to be changed

      initialSort: [
        //set the initial sort order of the data
        { column: "name", dir: "asc" }
      ],
      columns: [
        //define the table columns
        {
          title: "Name",
          field: "Name"
        },
        {
          title: "Phone",
          field: "Phone"
        },
        {
          title: "Owner",
          field: "OwnerId"
        }
        //{
        //  title: "Onwer",
        //  field: "Onwer.Name",
        //  editor: "select",
        //  editorParams: { values: ["male", "female"] }
        //}
      ]
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
