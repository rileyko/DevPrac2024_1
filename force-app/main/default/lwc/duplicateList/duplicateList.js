/**
 * @description       :
 * @author            : Woolim Ko
 * @group             : Trestle
 * @last modified on  : 01-09-2024
 * @last modified by  : Woolim Ko
 **/
import { LightningElement, api, wire } from "lwc";
import getTableData from "@salesforce/apex/DuplicateController.getQueryResult";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import TABULATOR from "@salesforce/resourceUrl/TabulatorFile";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import ACCT_FIELD from "@salesforce/schema/Account.Phone";
import CONT_FIELD from "@salesforce/schema/Contact.MobilePhone";
import LEAD_FIELD from "@salesforce/schema/Lead.Phone";

const fields = { Account: ACCT_FIELD, Contact: CONT_FIELD, Lead: LEAD_FIELD };
export default class duplicatList extends LightningElement {
  cols = [
    {
      title: "회사명",
      field: "name"
    },
    {
      title: "회사용 전화번호",
      field: "phone"
    },
    {
      title: "담당 영업",
      field: "ownername"
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
  @api objectApiName;
  table;
  data;
  isLoading = false;
  phoneField;

  /* --------------------------------------------------------------------------------------------------------
     * Lifecycle
    -------------------------------------------------------------------------------------------------------- */
  connectedCallback() {
    this.phoneField = fields[this.objectApiName];
  }

  renderedCallback() {
    console.log("rendered===============");
    if (this.tabulatorInitialized) {
      return;
    }
    this.tabulatorInitialized = true;
    this.init();
  }

  /* --------------------------------------------------------------------------------------------------------
* Apex
-------------------------------------------------------------------------------------------------------- */

  async getQueryResult() {
    this.data = await getTableData({ phoneNum: this.currentPhone });
  }

  /* --------------------------------------------------------------------------------------------------------
* Method
-------------------------------------------------------------------------------------------------------- */
  @wire(getRecord, {
    recordId: "$recordId",
    fields: "$phoneField"
  })
  currentRec;

  get currentPhone() {
    return getFieldValue(this.currentRec.data, this.phoneField);
  }

  async init() {
    try {
      this.isLoading = true;
      await this.loadTabulator();
      await this.getQueryResult();
      this.initiateTable();
    } catch (e) {
      console.error(e);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Initialize tabulator component
   * @memberof TabulatorExample
   * @private
   *
   * @example
   */
  async loadTabulator() {
    try {
      await Promise.all([
        loadScript(this, TABULATOR + "/tabulator-master/dist/js/tabulator.js"),
        loadStyle(this, TABULATOR + "/tabulator-master/dist/css/tabulator.css")
      ]);
    } catch (e) {
      console.error(e);
    }
  }
  initiateTable() {
    // eslint-disable-next-line no-undef
    this.table = new Tabulator(this.template.querySelector("div.tabulator"), {
      data: this.data,
      columns: this.cols,
      layout: "fitColumns",
      placeholder: "No Duplication Record",
      responsiveLayout: "hide", //hide columns that dont fit on the table
      pagination: "local", //paginate the data
      paginationSize: 7, //allow 7 rows per page of data
      paginationCounter: "rows", //display count of paginated rows in footer
      movableColumns: true, //allow column order to be changed
      initialSort: [{ column: "name", dir: "asc" }]
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
